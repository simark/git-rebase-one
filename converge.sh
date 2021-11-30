#!/usr/bin/env bash

set -x

steps=128

while true; do
  git-rebase-one "$1" "$steps"
  res=$?

  if [ $res == 0 ]; then
    # Great!
    true
  elif [ $res == 12 ]; then
    # Up-to date, great!
    exit 0
  elif [ $res == 13 ]; then
    # Rebase failed.
    if [ "$steps" -gt 1 ]; then
      git rebase --abort
      steps=$(("$steps" / 2))
    else
      exit 1
    fi
  fi
done
