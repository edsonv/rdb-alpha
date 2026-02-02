#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
TEAMS=$(
  cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOAL OPPONENT_GOALS;
  do
    if [[ $YEAR != "year" ]]
    then
      echo -e "$WINNER\n$OPPONENT"
    fi
  done | sort | uniq | sed "s/'/''/g"
)

VALUES=$(echo "$TEAMS" | sed "s/^/('/; s/$/')/" | sed ':a;N;$!ba;s/\n/,/g')

$PSQL "INSERT INTO teams(name) VALUES $VALUES ON CONFLICT (name) DO NOTHING;"

GAMES=$(
  cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOAL OPPONENT_GOALS;
  do
    if [[ $YEAR != "year" ]]
    then
      echo -e "$WINNER\n$OPPONENT"
    fi
  done | sort | uniq | sed "s/'/''/g"
)