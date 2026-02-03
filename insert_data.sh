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
  done | sort | uniq | sed "s/'/''/g; s/^/('/; s/$/')/;" | sed ':a;N;$!ba;s/\n/,/g'
)

GAMES=$(
  cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS;
  do
    if [[ $YEAR != "year" ]]
    then
      W=$(echo "$WINNER" | sed "s/'/''/g")
      O=$(echo "$OPPONENT" | sed "s/'/''/g")
      R=$(echo "$ROUND"   | sed "s/'/''/g")

      echo -e "($YEAR,'$R',(SELECT team_id FROM teams WHERE name='$W'),(SELECT team_id FROM teams WHERE name='$O'),$WINNER_GOALS,$OPPONENT_GOALS)"
    fi
  done | sed ':a;N;$!ba;s/\n/,/g'
)

QUERY="
  BEGIN;
  INSERT INTO teams(name) VALUES $TEAMS ON CONFLICT (name) DO NOTHING;
  INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES $GAMES;
  COMMIT;
"

$PSQL "$QUERY"