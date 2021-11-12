# Hades' Star Discord Bot

A simple discord bot I put together for helping to schedule/queue private Red Star runs. Pretty basic right now with all
the configuration done inside the source or (in a few instances) set via environmental variables.

## Installation

1. Fork this repository.
2. Create a new Heroku application and connect it to that repository.
3. Create Config Vars
    1. R2D2_RS_CHANNELS=_comma seperated redstar channel ids to monitor_
    2. R2D2_FUN_CHANNELS=_comma seperated fun channel ids to monitor_
    3. R2D2_CLIENT_ID=_client id of your discord app_
    4. R2D2_TOKEN=_bot token of your discord app's bot_
    5. R2D2_IMAGES_URL=_github content url to images folder, for example:_
        `https://raw.githubusercontent.com/USERNAME/hades-bot/main/app/images`
4. Start a worker process (requires the Heroku CLI installed)

```bash
heroku login
heroku scale worker=1 --app <app name here>
```
