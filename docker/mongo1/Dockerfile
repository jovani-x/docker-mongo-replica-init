FROM mongo:7.0.9

ARG MONGO_KEY_PATH
ARG MONGO_KEY_NAME
ARG MONGO_REPLICA_SET_NAME

# Install gettext for envsubst
RUN apt-get update && apt-get install -y gettext

# Create dir and save file with generated key for db there
RUN mkdir -p ${MONGO_KEY_PATH} \
		&& openssl rand -base64 756 > ${MONGO_KEY_PATH}/${MONGO_KEY_NAME} \
		&& chmod 400 ${MONGO_KEY_PATH}/${MONGO_KEY_NAME} \
		&& chown mongodb:mongodb ${MONGO_KEY_PATH}/${MONGO_KEY_NAME}

# Copy config file template
COPY /docker/mongo1/mongod.conf.template /etc/mongod.conf.template

# Replace placeholders in mongod.conf.template with environment variables
RUN envsubst '$MONGO_KEY_PATH,$MONGO_KEY_NAME,$MONGO_REPLICA_SET_NAME' < /etc/mongod.conf.template > /etc/mongod.conf

# Copy init script
COPY /docker/mongo1/mongo-init.sh /docker-entrypoint-initdb.d/mongo-init.sh

# Run mongod with config
CMD ["mongod", "--config", "/etc/mongod.conf"]
