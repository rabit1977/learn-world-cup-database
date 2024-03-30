#! /bin/bash

# Set the appropriate database connection command based on the environment
if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#start by emptying the rows in the tables of the database so we can rerun the file
echo $($PSQL "TRUNCATE TABLE games, teams")
# Read data from CSV file, excluding the header, and insert into tables
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  # Insert teams
  if [[ $WINNER != "Winner" && ! -z $WINNER ]]
  then 
    # Check if the winner team already exists in the teams table
    TEAM_EXIST=$($PSQL "SELECT EXISTS(SELECT 1 FROM teams WHERE name='$WINNER');")
    if [[ $TEAM_EXIST == "f" ]]
    then 
      # Insert the winner team into the teams table
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER');"
      echo "Inserted team: $WINNER"
      # Increment the counter for unique teams
    else
      echo "Team $WINNER already exists in the database."
    fi
  fi

  # Insert opponents
  if [[ $OPPONENT != "opponent" && ! -z $OPPONENT ]]
  then 
    # Check if the opponent team already exists in the teams table
    OPPONENT_EXIST=$($PSQL "SELECT EXISTS(SELECT 1 FROM teams WHERE name='$OPPONENT');")
    if [[ $OPPONENT_EXIST == "f" ]]
    then 
      # Insert the opponent team into the teams table
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');"
      echo "Inserted team: $OPPONENT"
      # Increment the counter for unique teams
    else
      echo "Team $OPPONENT already exists in the database."
    fi
  fi

  # Insert game data
  if [[ $YEAR != "year" ]]
  then
    # Get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    # Get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    # Insert game data into the games table
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
    echo "New game added: $YEAR, $ROUND, $WINNER_ID VS $OPPONENT_ID, score $WINNER_GOALS : $OPPONENT_GOALS"
  fi

done

