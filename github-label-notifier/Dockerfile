# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY functions/pubspec.* functions/
COPY symbolizer symbolizer
WORKDIR /app/functions
RUN dart pub get

# Copy app source code and AOT compile it.
COPY functions/ .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server
WORKDIR /app
# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/functions/bin/server /app/bin/

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]
