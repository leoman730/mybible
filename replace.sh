#!/bin/bash

#Call sample: ./replace.sh hb5_origin/gen/gen1.htm Genesis

source=$1
book=$2

[ -z "$2" ] && { echo "Please enter a name for the Book."; exit 1; }



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
