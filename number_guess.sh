#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#generate random number
TARGET=$(( RANDOM % 1001 ))

#prompt for username
echo "Enter your username:"
#get input for username
read USERNAME

#get games_played
GAMES_PLAYED=$($PSQL "SELECT games_played FROM stats WHERE username='$USERNAME'")
#get best_game
BEST_GAME=$($PSQL "SELECT best_game FROM stats WHERE username='$USERNAME'")


#if no games_played
if [[ -z $GAMES_PLAYED ]]
then
  #print to welcome new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  #insert user into stats() table
  INSERT_USER=$($PSQL "INSERT INTO stats(username, games_played) VALUES('$USERNAME', 0)")
  GAMES_PLAYED=0
else
  #print to welcome back user
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


#prompt to guess number
echo -e "\nGuess the secret number between 1 and 1000:"
#read input for guessed number
read GUESS
#increment number of guesses
NUM_GUESS=1

#loop until number is found
while [[ $GUESS != $TARGET ]]
do
  #if guess is not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    #prompt to guess again
    echo -e "\nThat is not an integer, guess again:"
  #else if guess is lower than target
  elif [[ $GUESS -lt $TARGET ]]
  then
    #prompt to guess again
    echo -e "\nIt's higher than that, guess again:"
  #else if guess is higher than target
  elif [[ $GUESS -gt $TARGET ]]
  then
    #prompt to guess again
    echo -e "\nIt's lower than that, guess again:"
  fi

  #read input number
  read GUESS
  #increment number of guesses 
  ((NUM_GUESS++))
done


#guess = target
#print successful guess
echo -e "\nYou guessed it in $NUM_GUESS tries. The secret number was $TARGET. Nice job!"
#increment games_played
((GAMES_PLAYED++))
INCREASE_GAMES=$($PSQL "UPDATE stats SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")

#if number of guesses < best_game
if [[ -z $BEST_GAME || $NUM_GUESS -lt $BEST_GAME ]]
then
  #replace stats(best_game) with guesses
  UPDATE_BEST_GAME=$($PSQL "UPDATE stats SET best_game=$NUM_GUESS WHERE username='$USERNAME'")
fi
