#!/bin/sh

command=$1
for_a=$2

check_heidi_root()
{
  if [ ! -e ./projects ] && [ ! -d ./projects ]
  then
    echo "You're not inside Heidi" >&2
    exit 1
  fi
}

case $command in
  new)
    mkdir -p $for_a/projects
  ;;
  project)
    check_heidi_root

    mkdir -p projects/$for_a/logs
    cd projects/$for_a
    git clone $2 cached
  ;;
  drop)
    check_heidi_root

    rm -r projects/$for_a
  ;;
end