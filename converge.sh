#!/usr/bin/env bash

set -eu

if [[ -z "${1:-}" ]]; then
  echo "Usage: converge.sh <target-ref>" >&2
  exit 1
fi

target_ref="$1"
steps=128
consecutive_successes=0
iteration=0

# Colors
GREEN='\033[32m'
RED='\033[31m'
BLUE='\033[34m'
YELLOW='\033[33m'
RESET='\033[0m'

echo -e "${BLUE}🎯 Converging towards $target_ref...${RESET}"

while true; do
  iteration=$((iteration + 1))
  echo -e "${BLUE}🔄 Iteration $iteration: attempting rebase with step size $steps${RESET}"

  res=0
  git-rebase-one "$target_ref" "$steps" || res=$?

  if [[ $res -eq 0 ]]; then
    consecutive_successes=$((consecutive_successes + 1))
    echo -e "${GREEN}✅ Rebase succeeded (consecutive successes: $consecutive_successes)${RESET}"

    if [[ $consecutive_successes -ge 2 ]]; then
      steps=$((steps * 2))
      echo -e "${YELLOW}⏫ Increasing step size to $steps${RESET}"
    fi
  elif [[ $res -eq 12 ]]; then
    echo -e "${GREEN}🎉 Up-to-date with $target_ref. Done!${RESET}"
    exit 0
  elif [[ $res -eq 13 ]]; then
    consecutive_successes=0
    if [[ $steps -gt 1 ]]; then
      echo -e "${YELLOW}⚠️  Rebase failed, aborting and reducing step size...${RESET}"
      git rebase --abort
      steps=$((steps / 2))
      echo -e "${YELLOW}⏬ Reduced step size to $steps${RESET}"
    else
      echo -e "${RED}❌ Rebase failed with step size 1. Manual intervention required.${RESET}"
      exit 1
    fi
  fi
done
