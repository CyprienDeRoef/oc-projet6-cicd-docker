# Stage 1: Build the Angular application
FROM node:20-alpine AS build

WORKDIR /build

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code and build the application
COPY . .
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy the built application from build stage to /app (as configured in nginx.conf)
# Note: Angular 17+ builds to dist/olympic-games-starter/browser
COPY --from=build /build/dist/olympic-games-starter/browser /app

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
