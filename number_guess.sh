#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"

MAIN() {
  RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
  USERNAME=''
  GAMES_PLAYED=0
  BEST_GAME=0
  ATTEMPTS=1

  GREET_USER
  GUESS_NUMBER
  UPDATE_INFO
}


GREET_USER() {
  echo "Enter your username:"
  read ENTERED_USERNAME

  USER=$($PSQL "SELECT * FROM users WHERE username='$ENTERED_USERNAME'")

  if [[ -z $USER ]] 
  then
    USERNAME=$( echo $($PSQL "INSERT INTO users(username) VALUES('$ENTERED_USERNAME') RETURNING username") | sed -E 's/ INSERT 0 1$//')
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    return
  fi
  
  read ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME <<< "$USER"
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
}

GUESS_NUMBER() {
  if [[ -z $1 ]]
  then
    echo "Guess the secret number between 1 and 1000:"
  else
    echo "$1"
  fi

  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    (( ATTEMPTS++ ))
    GUESS_NUMBER "That is not an integer, guess again:"
    return
  fi

  if [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    (( ATTEMPTS++ ))
    GUESS_NUMBER "It's lower than that, guess again:"
    return
  fi

  if [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    (( ATTEMPTS++ ))
    GUESS_NUMBER "It's higher than that, guess again:"
    return
  fi

  echo "You guessed it in $ATTEMPTS tries. The secret number was $RANDOM_NUMBER. Nice job!"
}

UPDATE_INFO() {
  (( GAMES_PLAYED++ ))
  if [[ $BEST_GAME -gt $ATTEMPTS || $BEST_GAME -eq 0 ]]
  then
    BEST_GAME=$ATTEMPTS
  fi
  
  USER=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
}

MAIN