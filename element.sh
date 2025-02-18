#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]] ; then
  echo "Please provide an element as an argument."
  exit
fi

# query function for less repetition
QUERY_DB() {
  # $1 = search query input from user
  # $2 = column name to query for
  if [[ -z $1 ]] ; then
    echo
  fi

  # verbose lookup with all column names
  echo "$($PSQL "select atomic_number,symbol,name,atomic_mass,melting_point_celsius,boiling_point_celsius,type from elements inner join properties using(atomic_number) inner join types using(type_id) where $2='$1'")"
}

# Prepare global variable to avoid parsing the result separately in each if statement
RESULT=""

if [[ $1 =~ ^[0-9]+$ ]] ; then
  
  # ID_LOOKUP_RESULT=$($PSQL "select atomic_number,symbol,name,atomic_mass,melting_point_celsius,boiling_point_celsius,type from elements inner join properties using(atomic_number) inner join types using(type_id) where atomic_number=$1")
  ID_LOOKUP_RESULT=$(QUERY_DB $1 "atomic_number")
  if [[ ! -z $ID_LOOKUP_RESULT ]] ; then
    RESULT="$ID_LOOKUP_RESULT"
  fi
else
  # Query exact shortcut
  SYMBOL_LOOKUP_RESULT=$(QUERY_DB $1 "symbol")
  if [[ ! -z $SYMBOL_LOOKUP_RESULT ]] ; then
    RESULT="$SYMBOL_LOOKUP_RESULT"
  fi

  # Query exact full name as last resort
  if [[ -z $SYMBOL_LOOKUP_RESULT ]] ; then
    FULL_LOOKUP_RESULT=$(QUERY_DB $1 "name")
    if [[ ! -z $FULL_LOOKUP_RESULT ]] ; then
      RESULT="$FULL_LOOKUP_RESULT"
    fi
  fi
fi

if [[ ! -z $RESULT ]] ; then
  # echo "$RESULT"

  # TESTS
  # if [[ $1 = 1 || $1 = "H" || $1 = "Hydrogen" ]] ; then

  #   # STRING EQUALITY TEST
  #   TEST_STRING="The element with atomic number 1 is Hydrogen (H). It's a nonmetal, with a mass of 1.008 amu. Hydrogen has a melting point of -259.1 celsius and a boiling point of -252.9 celsius."
  #   QUERY_RESULT=$(echo "$RESULT" | while IFS="|" read NUMBER SYMBOL FULL MASS MELT BOIL TYPE
  #   do
  #     echo "The element with atomic number $NUMBER is $FULL ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. Hydrogen has a melting point of $MELT celsius and a boiling point of $BOIL celsius."

  #     # put result in test file
  #     echo -n "The element with atomic number $NUMBER is $FULL ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. Hydrogen has a melting point of $MELT celsius and a boiling point of $BOIL celsius." > output.txt
  #   done)
  #   if [[ "$TEST_STRING" = "$QUERY_RESULT" ]] ; then
  #     echo "STRING EQUALITY Test passed"
  #   else
  #     echo "STRING EQUALITY Test failed"
  #   fi

  #   # DIFF 1c1 TEST
  #   if diff target.txt output.txt > /dev/null
  #     then
  #       echo "DIFF 1c1 TEST The files are equal"
  #     else
  #       echo "DIFF 1c1 TEST The files are different or inaccessible"
  #     fi
  # fi

  # Output successful result
  echo "$RESULT" | while IFS="|" read NUMBER SYMBOL FULL MASS MELT BOIL TYPE
    do
      echo "The element with atomic number $NUMBER is $FULL ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $FULL has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    done

  # Output if no result
  else
    echo "I could not find that element in the database."
fi

