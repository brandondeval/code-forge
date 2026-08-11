FROM node:22.16-alpine

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Clean npm cache and install Node.js dependencies
# Then, explicitly rebuild native modules to ensure they are compiled for the Alpine environment
RUN npm ci

# Copy the rest of your application code
COPY . .

# Copy the schema.sql file into the container
COPY schema.sql /app/schema.sql

# Create a directory for the database if it doesn't exist (important for volume mounting)
RUN mkdir -p /app/data

# Expose the port your Node.js app runs on
EXPOSE 3001

# Command to run your application:
# First, ensure the database file exists and then execute the schema.sql script against it.
# The 'sh -c' allows for running multiple commands sequentially.
# It uses 'sqlite3 /app/data/database.sqlite' to target the database file within the volume.
# '< /app/schema.sql' pipes the schema file content to sqlite3 for execution.
# 'npm start' then starts your Node.js application.
CMD sh -c "touch /app/data/database.sqlite && sqlite3 /app/data/database.sqlite < /app/schema.sql && npm start"