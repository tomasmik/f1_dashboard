# 🏎️ F1 Dashboard
A real-time Formula 1 dashboard built with Phoenix LiveView using the [OpenF1 API](https://openf1.org/). Stateless, easy, and simple - the only dependency is a connection to the API.

![Elixir](https://img.shields.io/badge/elixir-%3E%3D1.14-blueviolet)
![Phoenix](https://img.shields.io/badge/phoenix-%3E%3D1.7-orange)

## Features
- (Almost) Live race timing and positions
- (Some) Driver telemetry and speed data
- Session information and weather

There are some limitations because we're using the free version of the API.
Data streaming isn't available, so we have to poll the API for new data.
This means the data isn't exactly "live", but it's pretty close to the live broadcast.

See [screenshots](./screenshots/) for a visual example. 

## Setting up OpenF1 
The project requires either the paid or self-hosted version of OpenF1 API.
Their regular API is disabled during live races, so it won't work with this application.

You can set up OpenF1 locally by following [their guide](https://github.com/br-g/openf1?tab=readme-ov-file#running-the-project-locally). It will only ingest new race data, so you must set it up before the race starts. Make sure you enable [services/ingestor_livetiming/](src/openf1/services/ingestor_livetiming/README.md) and [services/query_api/](src/openf1/services/query_api/README.md).

To test the app, you can use the public API: https://api.openf1.org

## Setting up the application 
Check out the `.env.example` and `docker-compose` for more detailed and up-to-date instructions.

You can set these environment variables:
```
OPEN_F1_BASE_URL=https://api.openf1.org
SECRET_KEY_BASE=52649bd5abc721c074f40552d86c138264bff3fa24c1618521ad096b7c80845a
PORT=4000
PHX_HOST="localhost"
```

You can get the [image on Dockerhub](https://hub.docker.com/r/tomasmik/f1dashboard)

## Local Setup
```bash
mix deps.get
mix phx.server
```

Visit `localhost:4000`

## Disclaimer
This is an unofficial project and is not affiliated with Formula 1 companies. All F1-related trademarks are owned by Formula One Licensing B.V.