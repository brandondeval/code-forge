FROM node:22.16-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of your application code
COPY . .

# Build the React app for production using Vite
# Vite typically outputs to a 'dist' folder by default
RUN npm run build


# Stage 2: Serve the built application with Nginx
FROM nginx:alpine

# Copy the Nginx default configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Remove the default Nginx HTML files
RUN rm -rf /usr/share/nginx/html/*

# Copy the built React application from the 'build' stage to the Nginx web root
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Command to run Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]