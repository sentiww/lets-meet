#!/usr/bin/env bash

SCRIPT_PATH=$(realpath "$0")
PROJECT_PATH=$(dirname $(dirname "$SCRIPT_PATH"))

if [ -z "$1" ]; then
  echo "Please provide an argument."
  echo "- update"
  echo "- new"
  exit 1
fi

if [ "$1" == "update" ]; then
  dotnet-ef database update --project "$PROJECT_PATH"/backend/LetsMeet.Persistence/LetsMeet.Persistence.csproj
elif [ "$1" == "new" ]; then
  if [ -z "$2" ]; then
    echo "Please provide a migration name."
    exit 2
  fi
  
  dotnet-ef migrations add "$2" --project "$PROJECT_PATH"/backend/LetsMeet.Persistence/LetsMeet.Persistence.csproj
fi