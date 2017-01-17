#!/bin/bash


source=$1
destination='transformed/'$1
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


# Join all the newline together
# Reference: http://www.thegeekstuff.com/2012/12/linux-tr-command/
cat $destination | tr -s '\n' ' ' > $destination'.tmp'
mv $destination'.tmp' $destination



# Add new line to the beginning of each verb
cat $destination | sed -E 's/([0-9]:[0-9]+)/\n\1/g' > $destination'.tmp'
mv $destination'.tmp' $destination
# cat $destination

# Reference: https://jaywcjlove.github.io/linux-command/c/awk.html
awk 'BEGIN{ FS=":" } { print $NF }' $destination

# cat $destination | awk -fs ':' '{print $2}'



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
