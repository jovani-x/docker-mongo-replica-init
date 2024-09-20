# Docker with mongo and automatic initialization of replication

It is a simple way to run mongoDB with automatic initialization of replica in one command only.

_It's just for local development only due to:_ `WARN: SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions for sensitive data (ARG "MONGO_KEY_PATH" and "MONGO_KEY_NAME")`

### Features:

- quick start without extra steps and preparing (if you have docker)
- automatically inserting variables into the mongod.conf file
- minimal required settings

### Details:

- mongo-init.sh creates users and shutdowns mongod
- docker runs mongod
- replica set is initialized in healthcheck

### Usual way:

- run mongod without replica set
- connect to it
- create admin user
- create app db user
- restart mongod with replica set (shutdown and run again)
- auth and init replica

## Run

### 1. Start mongo image

```
docker compose up -d
```

### 2. Wait a little bit and check replica status

in terminal:

```
docker exec -it mongo_app_container mongosh --authenticationDatabase admin -u superuser -p superuserpass appdb --eval "rs.status();"
```

or in the docker container terminal:

```
mongosh --authenticationDatabase admin -u superuser -p superuserpass appdb --eval "rs.status();"
```

```
/*
mongo_app_container - container name
admin - admin db name
superuser - admin user name
superuserpass - admin user password
appdb - app db name
*/
```

answer should be something like:

```
{
	...
	set: 'replicaSetCustomName',
	...
	ok: 1,
	...
}
```

### 3. Stop mongo image

```
docker compose down
```

## Extra info and refs to the official docs

[Localhost Exception](https://www.mongodb.com/docs/manual/core/localhost-exception/)

[Use SCRAM to Authenticate Clients on Self-Managed Deployments](https://www.mongodb.com/docs/manual/tutorial/configure-scram-client-authentication/)

Default etrypoint of mongo image is `/usr/local/bin/docker-entrypoint.sh`.

Some extra scripts can be added to `/docker-entrypoint-initdb.d/` (these scripts run once only).
