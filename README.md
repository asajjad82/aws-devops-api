# aws-devops-api

Small JSON REST API (Node.js / Express) used to learn DevOps and AWS.

## Run locally

    npm install
    npm start

## Run with Docker

    docker build -t aws-devops-api:1.0 .
    docker run --rm -p 3000:3000 aws-devops-api:1.0

## Endpoints

- `GET /health`
- `GET /items`, `GET /items/:id`
- `POST /items` with `{"name": "..."}`
- `DELETE /items/:id`