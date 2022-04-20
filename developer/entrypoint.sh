#!/bin/sh

# Note: !/bin/sh must be at the top of the line,
# Alpine doesn't have bash so we need to use sh.
# Docker entrypoint script.
# Don't forget to give this file execution rights via `chmod +x entrypoint.sh`
# which I've added to the Dockerfile but you could do this manually instead.

# Wait until Postgres is ready before running the next step.
while ! pg_isready -q -h $DB_HOSTNAME -p 5432 -U $DB_USERNAME
do
  echo "$(date) - waiting for database to start."
  sleep 2
done


print_db_name()
{
  `PGPASSWORD=$DB_PASSWORD psql -h $DB_HOSTNAME
  -U $DB_USERNAME -Atqc "\\list $DB_NAME"`
}


# Create the database if it doesn't exist.
if [[ print_db_name ]]; then
  # Runs migrations, will skip if migrations are up to date.
  echo "Database $DB_NAME exists, running migrations..."
  mix ecto.migrate
  echo "Migrations finished."
fi


# Start the server.
exec mix phx.server