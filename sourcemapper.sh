#!/bin/bash

# check if a url has been supplied
if [ -z "$1" ]; then
  echo "Please supply a sourcemap URL"
  exit 1;
fi

# store url with sourcemap filename
URL=$1
# store url without sourcemap filename
URLNOMAP=$(echo $URL | rev | cut -d '/' -f2- | rev)

# check if url is sourcemap or js
if [ $(echo $URL | rev | awk -F'.' '{print $1}' | rev) != 'map' ]; then
  # If not .map check for a sourcemap reference
  MAPFILE=$(curl -s $URL | grep sourceMapping | sed -e 's/.*sourceMappingURL=\([[:alnum:][:punct:]]*\)/\1/')
  if [ -z $MAPFILE ]; then
    echo "No sourcemap referenced in $URL"
    exit 1
  fi
  URL="$URLNOMAP/$MAPFILE"
  echo "Found reference to $URL"
fi

# disable wildcard expansion
set -f

# check if file exists at all
RESP=$(curl -s -o /dev/null -w "%{http_code}" $URL)
if [ "$RESP" != '200' ]; then
  echo "Map not found. (HTTP Response Code: $RESP)";
  exit 1;
fi

# pull contents of the file into $MAP
MAP=$(curl -s "$URL");

# is it even valid json?
echo "$MAP" | jq > /dev/null 2>&1
if [ $? != 0 -a $? != 2 ]; then
  echo "Map contains invalid JSON."
  exit 1;
fi

# Version?
VER=$(echo $MAP | jq '.version' 2> /dev/null);
if [ "$VER" != '3' ]; then
    echo "This tool has only been tested with version 3 of the sourcemap spec."
    echo "the requested sourcemap returned a version of: $VER. Trying anyway."
fi

echo "Map loaded: read $(echo $MAP | wc -c) bytes from $(echo $URL | rev | awk -F'/' '{print $1}' | rev)."

# get the number of files, the directory structure, and the file contents
LENGTH=$(echo $MAP | jq '.sources[]' 2> /dev/null | wc -l);
CONTENTS=$(echo $MAP | jq '.sourcesContent' 2> /dev/null );
SOURCES=$(echo $MAP | jq '.sources' 2> /dev/null );

echo "$LENGTH files to be written."
COUNTER=$LENGTH

for ((i=0;i<=LENGTH;i++)); do
  printf "$COUNTER files remaining."
  # for each file: get the path without the filename, remove ../'s, remove quotes
  P=$(echo $SOURCES | jq .[$i] | rev | cut -d '/' -f2- | rev | sed 's/\"//g');
  # get the filename without the path
  F=$(echo $SOURCES | jq .[$i] | rev | awk -F'/' '{print $1}' | rev | sed 's/\"//g');

  # check for source in sourcesContent, otehrwise get directly from the URL.
  DATA=$(echo $CONTENTS | jq .[$i] | cut --complement -c 1 | rev | cut --complement -c 1,2,3 | rev)
  if [ "$DATA" == 'null' ]; then
    DATA=$(curl -s "$URLNOMAP/$P/$F")
  fi

  # create directories to match the paths in the map, eliminate ../'s
  BASE='./sourcemaps';
  P=$(echo $P | sed 's/\.\.\///g' )
  mkdir -p "$BASE/$P";

  # create the file at that location
  echo -ne "$(echo $DATA | sed 's/%/%%/g')\n" > "$BASE/$P/$F";
  echo -ne "\rWriting: $BASE/$P/$F\n"
  ((COUNTER=COUNTER-1))

done
