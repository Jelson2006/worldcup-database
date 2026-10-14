#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

team_values=""
game_values=""

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  if [[ -n $team_values ]]
  then
    team_values+=","
    game_values+=","
  fi
  team_values+="('$winner'),('$opponent')"
  game_values+="($year,'$round','$winner','$opponent',$winner_goals,$opponent_goals)"
done < <(tail -n +2 games.csv)

$PSQL "INSERT INTO teams(name) VALUES $team_values ON CONFLICT (name) DO NOTHING;
INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
SELECT data.year, data.round, winners.team_id, opponents.team_id, data.winner_goals, data.opponent_goals
FROM (VALUES $game_values) AS data(year, round, winner, opponent, winner_goals, opponent_goals)
JOIN teams AS winners ON winners.name = data.winner
JOIN teams AS opponents ON opponents.name = data.opponent;"
