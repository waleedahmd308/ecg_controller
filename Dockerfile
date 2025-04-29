# Use official Dart image to build the app
FROM dart:stable AS build

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy all project files
COPY . .

# Build the Flutter web app (if you are targeting web)
RUN flutter pub get
RUN flutter build web

# ----

# Use a simple web server to serve the built app
FROM nginx:alpine

# Copy build files from previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]
