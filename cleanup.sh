# !/usr/bin/env bash

export CHECK="\xE2\x9C\x94"
export CROSS="\xE2\x9D\x8C"

export HOMEDIR="/home/ide"
export PROJECT_DIR="${HOMEDIR}/project"
export MYSQL_CONNECT="mysql -udrupal -pdrupal"
export D9_DB="drupal9"
export D7_DB="drupal"

function cleanup_mysql() {
  ${MYSQL_CONNECT} -e "DROP DATABASE ${D9_DB}" > /dev/null 2>&1
  echo -e "${CHECK} Deleted '${D9_DB}' database."
  ${MYSQL_CONNECT} -e "DROP DATABASE ${D7_DB}" > /dev/null 2>&1
  ${MYSQL_CONNECT} -e "CREATE DATABASE ${D7_DB}" > /dev/null 2>&1
  echo -e "${CHECK} Emptied '${D7_DB}' database"
}

function reset_project_directory() {
  if [[ -f ${PROJECT_DIR}/composer.json ]]; then
    cd "${PROJECT_DIR}"
    rm -rf ..?* .[!.]* * || exit
    echo -e "${CHECK} Cleaned up project directory."
  fi
}

function main() {
  while [[ -z $OPTION ]]; do
    read -p "Are you sure you want to wipe all files and directories under ${PROJECT_DIR} and reset databases? (Y/n): " OPTION
  done

  if [[ $OPTION == [yY] ]]; then
    echo
    cleanup_mysql
    reset_project_directory
  elif [[ $OPTION == [nN] ]]; then
    echo -e "\nExiting..."
    exit 0
  else
    OPTION=""
    echo -e "\nTo continue you need to enter exactly Y or y.\n"
    main
  fi
}

main
