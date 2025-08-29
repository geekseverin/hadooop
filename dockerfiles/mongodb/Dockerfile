FROM mongo:latest

# Copy data loading script
COPY scripts/setup/load-data.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/load-data.sh

EXPOSE 27017