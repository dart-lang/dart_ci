# App Engine Deployment

This directory contains the configuration and source code for the `dart_ci/appengine` App Engine service.
The application runs in the **App Engine Flexible Environment** using a custom runtime (Docker).

## Deployment

To deploy the application, run:

```bash
gcloud app deploy
```

## Verification

Once deployed, verify the application is running:

```bash
gcloud app browse
```

## Local Development

To run the application locally using Docker:

1.  **Build the image**:
    ```bash
    docker build -t dart-ci-app .
    ```

2.  **Run the container**:
    ```bash
    docker run -it -p 8080:8080 --env PORT=8080 dart-ci-app
    ```

3.  Access the app at `http://localhost:8080`.
