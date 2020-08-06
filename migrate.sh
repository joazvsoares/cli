# !/usr/bin/env bash

export CHECK="\xE2\x9C\x94"
export CROSS="\xE2\x9D\x8C"

export HOMEDIR="/home/ide"
export PROJECT_DIR="${HOMEDIR}/project"
export ZIP_FILE="acquia-migrate-accelerate-private-beta.zip"
export SQL_FILE="acquia_migrate_accelerate.sql"
export D9_DB="drupal9"
export D7_DB="drupal"
export ZIP_URL=$1

if [ -z "$ZIP_URL" ]; then
  echo -e "${CROSS} Missing required parameter in the command line. It MUST be with the format: migrate <url>/${REMOTEIDE_LABEL}/acquia-migrate-accelerate-beta.zip"
  exit 1
fi

function prevent_dirty_state() {
  if [[ -f composer.json ]]; then
    echo -e "${CROSS} Cannot run the migration script as the project directory is not empty.\n"
    echo -e "Detected the below files:\n"
    ls -a
    exit 1
  fi
}

function check_zip_file_exists_remotely() {
  if [[ $(wget -S --spider ${ZIP_URL} 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then
    echo -e "${CHECK} Found ZIP file on the remote server.";
  else
    echo $ZIP_URL
    echo -e "${CROSS} The ZIP file could not be found on the remote server. The URL MUST contain ${REMOTEIDE_LABEL}/acquia-migrate-accelerate-beta.zip"
    exit 1
  fi
}

function download_zip_file() {
  if [[ ! -f ${PROJECT_DIR}/${ZIP_FILE} ]]; then
    curl -O --silent ${ZIP_URL}
    echo -e "${CHECK} Downloaded ZIP file."
  fi
}

function deflate_zip_file() {
  if [[ -f ${PROJECT_DIR}/${ZIP_FILE} ]]; then
    unzip -q ${ZIP_FILE}
    echo -e "${CHECK} Deflated ZIP file."
  else
    echo -e "${CROSS} Could not find a ZIP file to deflate."
    exit 1
  fi
}

function fix_drupal_permissions() {
  chmod -R u+w docroot/sites/default
  echo -e "${CHECK} Fixed Drupal permissions."
}

function create_database() {
  mysql -u root -e "CREATE DATABASE ${D9_DB}"
  mysql -u root -e "GRANT ALL PRIVILEGES ON drupal9.* TO 'drupal'@'localhost'"
  echo -e "${CHECK} Created '${D9_DB}' database."
}

function import_sql_file() {
  if [[ -f ${SQL_FILE} ]]; then
    mysql -u drupal -pdrupal ${D9_DB} < ${SQL_FILE} > /dev/null 2>&1
    echo -e "${CHECK} Imported SQL file."
  else
    echo -e "${CROSS} Could not find the SQL file to import."
    exit 1
  fi
}

function delete_zip_file() {
  if [[ -f ${ZIP_FILE} ]]; then
    rm ${ZIP_FILE} || exit
    echo -e "${CHECK} Deleted ZIP file."
  else
    echo -e "${CROSS} Could not find a ZIP file to delete."
    exit 1
  fi
}

function delete_sql_file() {
  if [[ -f ${SQL_FILE} ]]; then
    rm ${SQL_FILE} || exit
    echo -e "${CHECK} Deleted SQL file."
  else
    echo -e "${CROSS} Could not find a SQL file to delete."
    exit 1
  fi
}

function main() {
  cd ${PROJECT_DIR}
  prevent_dirty_state
  check_zip_file_exists_remotely
  download_zip_file
  deflate_zip_file
  fix_drupal_permissions
  create_database
  import_sql_file
  delete_zip_file
  delete_sql_file
}

main
