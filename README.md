# Hades' Star Discord Bot

A simple discord bot I put together for helping to schedule/queue private Red Star runs. Pretty
basic right now with all the configuration done inside the source or (in a few instances) set
via environmental variables.

## Installation

1. Fork this repository.
2. Create a new Heroku application and connect it to that repository.
3. Create Config Vars
  1. R2D2_CHANNELS=_comma seperated channel ids to monitor_
  2. R2D2_CLIENT_ID=_client id of your discord app_
  3. R2D2_TOKEN=_bot token of your discord app's bot_
4. Start a worker process (requires the Heroku CLI installed)

```bash
heroku login
heroku scale worker=1 --app <app name here>
```
