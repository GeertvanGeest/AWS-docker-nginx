#!/usr/bin/env bash

USAGE="Usage: generate_credentials -l <user list> [-o <output file>] \n
\n
This command generates credentials for users. Writes to stdout.\n
\n
-l  tab-delimited list of users, with 2 columns: first name and last name. Required. \n
"

while getopts ":l:o:" opt
do
  case $opt in
    l)
      LIST=$OPTARG
      ;;
    \?)
      echo -e "Invalid option: -$OPTARG \n" >&2
      echo -e $USAGE >&2
      exit 1
      ;;
    :)
      echo -e "Option -$OPTARG requires an argument. \n"
      echo -e $USAGE >&2
      exit 1
      ;;
  esac
done

# return usage if no options are passed
if [ $OPTIND -eq 1 ]
then
  echo -e "No options were passed. \n" >&2
  echo -e $USAGE >&2
  exit 1
fi

# ignore foreign characters
export LC_ALL=C

# required options
if [ "$LIST" == "" ]; then echo "option -l is missing, but required">&2 && exit 1; fi

# get script source directory to not break secondary script dependencies
SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

TMPULIST=`mktemp`
TMPTNAMES=`mktemp`
TMPUNAMES=`mktemp`
TMPPASSWD=`mktemp`
TMPCOMB=`mktemp`

# check if end of file new line exists
# and add it if not
cat $LIST | tail -c1 | read -r _ || echo >> $LIST

# removing carriage returns and spaces
cat $LIST | tr -d '\015\040' > $TMPULIST

LIST=$TMPULIST

FIRSTL=`cat "$LIST" | cut -f 1 | tr -cd '\11\12\15\40-\176' | tr [:upper:] [:lower:] | cut -c-1`
LASTN=`cat "$LIST" | cut -f 2 | tr -cd '\11\12\15\40-\176' | tr [:upper:] [:lower:]`

USERNAMES=$(paste -d '-' <(echo "$FIRSTL") <(echo "$LASTN") | tr -d '-')

cat "$LIST" > $TMPTNAMES

paste $TMPTNAMES <(echo $USERNAMES | tr ' ' '\n') >> $TMPUNAMES

rm $TMPTNAMES

# generate empty password file
if [ -f $TMPPASSWD ]
then
  rm $TMPPASSWD
  touch $TMPPASSWD
fi

for user in $USERNAMES
do
    openssl rand -base64 14 >> $TMPPASSWD
done

paste $TMPUNAMES $TMPPASSWD \
| awk -v OFS='\t' 'BEGIN {print "first", "last", "username", "password"}{print $0}' 
