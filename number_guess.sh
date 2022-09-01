#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 ))
GUESS_COUNT=0

GUESS_NUMBER() {
  if [[ -n $1 ]]
  then
    echo $1
  fi

  read GUESS
  GUESS_COUNT=$(($GUESS_COUNT + 1))
  if [[ ! $GUESS =~ ^[0-9]*$ ]]
  then
    GUESS_NUMBER "That is not an integer, guess again:"
  else
    if (( $GUESS > $NUMBER ))
    then
      GUESS_NUMBER "It's lower than that, guess again:"
    elif (( $GUESS < $NUMBER ))
    then
      GUESS_NUMBER "It's higher than that, guess again:"
    elif (( $GUESS == $NUMBER ))
    then
      GAMES_PLAYED=$(($GAMES_PLAYED + 1))
      if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]
      then
        BEST_GAME=$GUESS_COUNT
        UPDATE_BEST=$($PSQL "UPDATE players SET best_game = $BEST_GAME WHERE username = '$USERNAME'")
      fi
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
      echo -e "Would you like to play again?\ny/n"
      read PLAY_AGAIN
      if [[ $PLAY_AGAIN == 'y' || $PLAY_AGAIN == 'yes' || $PLAY_AGAIN == 'Y' || $PLAY_AGAIN == 'Yes' ]]
      then
        NUMBER=$(( RANDOM % 1000 ))
        GUESS_COUNT=0
        GUESS_NUMBER "Guess the secret number between 1 and 1000:"
      fi
    fi
  fi
}

echo Enter your username:
read USERNAME
PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")
if [[ -z $PLAYER_ID ]]
then
  INSERT_PLAYER=$($PSQL "INSERT INTO players(username, games_played) VALUES('$USERNAME', 0)")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
GUESS_NUMBER "Guess the secret number between 1 and 1000:"
