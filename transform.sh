#!/bin/bash


# [ -z "$1" ] && { echo "Please enter a path."; exit 1; }
# [ -z "$2" ] && { echo "Please enter a name for the Book."; exit 1; }


#normal=$(tput sgr0)                      # normal text
normal=$'\e[0m'                           # (works better sometimes)
bold=$(tput bold)                         # make colors bold/bright
red="$bold$(tput setaf 1)"                # bright red text
green=$(tput setaf 2)                     # dim green text
fawn=$(tput setaf 3); beige="$fawn"       # dark yellow text
yellow="$bold$fawn"                       # bright yellow text
darkblue=$(tput setaf 4)                  # dim blue text
blue="$bold$darkblue"                     # bright blue text
purple=$(tput setaf 5); magenta="$purple" # magenta text
pink="$bold$purple"                       # bright magenta text
darkcyan=$(tput setaf 6)                  # dim cyan text
cyan="$bold$darkcyan"                     # bright cyan text
gray=$(tput setaf 7)                      # dim white text
darkgray="$bold"$(tput setaf 0)           # bold black = dark gray text
white="$bold$gray"                        # bright white text

# echo "${red}hello ${yellow}this is ${green}coloured${normal}"
# exit 1;


function process () {
  source=$1
  book=$2

  echo "${green}Read file: $1${normal}"
  
  destination='transformed/'$1'.txt'
  mkdir -p "$(dirname "$destination")" && touch "$destination"

  # Convert source file to UTF-8 charset
  # Reference: https://blog.gtwang.org/tips/iconv-convert-text-big5-between-utf8-encoding/
  iconv -f BIG5-2003 -t UTF-8 $source > $destination

  # Identify the line of text that we want
  grep --color -e '^</a>$' -e '</table>$' -e '<tr>$' -e '[0-9]:[0-9]*' $destination > $destination'.tmp'
  mv $destination'.tmp' $destination

  # Then send them to sed to remove unwant markup
  sed -e 's/<tr>//' \
      -e 's/<\/table>//' \
      -e 's/<\/font>//' \
      -e 's/<\/a>//' $destination > $destination'.tmp'

  mv $destination'.tmp' $destination
  # cat $destination

  # Join all the newline together
  # Reference: http://www.thegeekstuff.com/2012/12/linux-tr-command/
  cat $destination | tr -s '\n' ' ' > $destination'.tmp'
  mv $destination'.tmp' $destination
  # cat $destination


  # Add new line to the beginning of each verb, also append ':' at the end for verb number
  cat $destination | sed -E 's/([0-9]+:[0-9]+)/\n\1:/g' > $destination'.tmp'
  mv $destination'.tmp' $destination
  # cat $destination

  # Reference: https://jaywcjlove.github.io/linux-command/c/awk.html
  awk -v BOOK=$book 'BEGIN{ FS=":"} { print BOOK "\t" $1 "\t"$2 "\t"BOOK " "$1":"$2"\t"$3 }' $destination > $destination'.tmp'
  mv $destination'.tmp' $destination

  # cat $destination

  # Print anyline that starts with number or in another word, remove empty line
  # Reference: http://www.unix.com/shell-programming-and-scripting/151050-deleting-lines-not-starting-numbers-sed.html
  sed -n '/[0-9]/p' $destination > $destination'.tmp'
  mv $destination'.tmp' $destination


  # Adding a header row for drpual import
  echo -e "book\tchapter\tverse\ttitle\tbody\n$(cat $destination)" > $destination

  cat $destination

  cp $destination ~/Desktop/test.csv
  # grep --color -h '^[^<]' gen1.html |
  # sed -e 's/<a href="#top">//' \
  #     -e 's/Return to top of page<\/font>//' \
  #     -e 's/Next Chapter<\/a>//' \
  #     -e 's/<a TARGET=_top HREF="..\/..\/hb5.htm">//' \
  #     -e 's/Talbe of Contents<\/A>//' \
  #     -e 's/<a href="..\/..\/search.htm">//' \
  #     -e 's/<a href="..\/..\/index.htm">//' \
  #     -e 's/Search in Bible<\/a>//' \
  #     -e 's/<a href="http:\/\/www.ccim.org">//' \
  #     -e 's/Chinese Christian Internet Mission<\/a>//' \
  #     -e 's/Online Bible<\/a>//' \
  #     -e 's/<\/center>//' \
  #     -e 's/<p>//' \
  #     -e 's/<\/p>//' \
  #     -e 's/<\/body>//' \
  #     -e 's/<\/html>//' \
}



if [ -z "$1" ] || [ -z "$2" ]; then
 echo "${red}Usage: ./transform.sh {Path} {Book}"
 echo "Example: ./transform.sh hb5_origin/psm/ Psalms${normal}"
 exit 1;
fi


# Read file name from a directory
DIR=$1
BOOK=$2


# echo $DIR
# DIR=hb5_origin/psm/*

if [ ! -d $DIR ]; then
  echo "${red}The directory '$DIR' not exists!${normal}"
  exit 1;
fi 

# the xargs is used to remove whitespace
echo "${green}There are `find $DIR -type f | wc -l | xargs` files in $DIR${normal}."


read -e -p "${green}Do you want to start a batch process for al files (Y/N)?${normal}" batch_process

# Note: gls is a util from mac. download: brew install coreutils
# gls -v is an equivalent version of the GNU version ls -v, which sort string that contains numeric value
for f in `gls -v $DIR/*` 
do
  if [ -f $FILE ]; then
    # echo "${green}Read file: $f${normal}"
    
    if [[ ! $batch_process =~ ^[Yy]$ ]]; then
      read -e -p "${green}Process next file? (Y/N): ${normal}" answer
    
      process $f $BOOK  
      
      # prompt user to transform next file
      if [[ ! $answer =~ ^[Yy]$ ]]; then # =~  is regular expression match as '='
        exit 1;
      fi
      
    else
      process $f $BOOK
    fi
    
    
  else
    echo "File $f not exists"
  fi
done


# Next we want to combine all transform files into a single master files
echo "${green}Now we want to combine all transform files into a single master files.${normal}"
read -e -p "${green}Give a name for the file (ex: psm): ${normal}" book
if [[ ! $book = '' ]]; then
  echo "${green}Transforming transformed/hb5_origin/$book/* into $book.txt${normal}"
  gls -v transformed/hb5_origin/${book}/* | xargs cat  > ${book}.txt
  # gls -v transformed/hb5_origin/psm/* | xargs cat > psm.txt
  
  # Clean up extra headers 'book title chapter etc.'
  sed -e '/^book.*$/d' $book.txt > $book'.tmp'

  mv $book'.tmp' $book.txt
  
  # Add a header  
  echo -e "book\tchapter\tverse\ttitle\tbody\n$(cat $book.txt)" > $book.txt
fi



