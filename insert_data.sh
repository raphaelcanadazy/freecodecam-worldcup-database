#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams,games RESTART IDENTITY")

# Read games.csv Insert data for TABLE teams
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" || $OPPONENT != "opponent" ]]
  then
    if [[ $WINNER != name ]]
    then
      NAME=$($PSQL "SELECT name from teams WHERE name='$WINNER'")

      if [[ -z $NAME ]]
      then
        INSERT_TEAM_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
        if [[ $INSERT_TEAM_WINNER_RESULT == "INSERT 0 1" ]]
        then
          echo "Insert into teams winner, $WINNER"
        fi
      fi
    fi

    if [[ $OPPONENT != name ]]
    then
      NAME=$($PSQL "SELECT name from teams WHERE name='$OPPONENT'")

      if [[ -z $NAME ]]
      then
        INSERT_TEAM_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
        if [[ $INSERT_TEAM_OPPONENT_RESULT == "INSERT 0 1" ]]
        then
          echo "Insert into teams opponent, $OPPONENT"
        fi
      fi
    fi
  fi
done

# Read games.csv Insert data for TABLE games
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  if [[ -n $WINNER_ID && -n $OPPONENT_ID ]]
  then
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Insert into games, $YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS"
    fi
  fi
done