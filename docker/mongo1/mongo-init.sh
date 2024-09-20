#!/bin/bash

# Define variables
ADMIN_DB_BASE=${MONGO_INITDB_DATABASE}
ADMIN_USER=${MONGO_INITDB_ROOT_USERNAME}
ADMIN_PASS=${MONGO_INITDB_ROOT_PASSWORD}
DB_NAME=${MONGO_DB_NAME}
DEV_USER=${DB_USER}
DEV_PASS=${DB_PASS}

# Define functions
connect_and_run_until_success() {
	# Command passed as a parameter
	local mongo_command="$1"
	# Connect without any params, only run command
	mongosh --eval "$mongo_command"
}

auth_and_run_until_success() {
	# Command passed as a parameter
	local mongo_command="$1"
	# Connect with auth
	mongosh --authenticationDatabase $ADMIN_DB_BASE --host localhost -u $ADMIN_USER -p $ADMIN_PASS $DB_NAME --eval "$mongo_command"
}

# Create admin db user
create_admin_db_user() {
	connect_and_run_until_success "var dbAdmin = { user: '$ADMIN_USER', pwd: '$ADMIN_PASS', roles: [{ role: 'root', db: '$ADMIN_DB_BASE' }] }; db.createUser(dbAdmin);"
}

# Create app db user
create_app_db_user() {
	auth_and_run_until_success "var dbUser = { user: '$DEV_USER', pwd: '$DEV_PASS', roles: [{ role: 'readWrite', db: '$DB_NAME' }] }; db.getSiblingDB('$DB_NAME').createUser(dbUser);"
}

create_users() {
	create_admin_db_user
	# Wait until admin user be created
	until auth_and_run_until_success "var admUsr = db.system.users.findOne({ user: '$ADMIN_USER', db: '$ADMIN_DB_BASE' }); admUsr !== null" >/dev/null 2>&1; do
		create_admin_db_user
		sleep 3
	done

	create_app_db_user
	# Wait until app db user be created
	until auth_and_run_until_success "var appUsr = db.system.users.findOne({ user: '$DEV_USER', db: '$DB_NAME' }); appUsr !== null" >/dev/null 2>&1; do
		create_app_db_user
		sleep 3
	done
}

# Wait 10 seconds
sleep 10
create_users

# Shutdown mongod
# it will be restarted automatically ('restart: always' in compose)
mongod --shutdown
