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

## Creating a Discord Application

1. Head over to the [Discord Developer Portal](https://discord.com/developers/applications), sign up for free account
   if you haven't already.
2. Click New Application
3. Give it a Name and click **Create**

## Create a Bot

1. Head over to the [Discord Developer Portal](https://discord.com/developers/applications)
2. Select the application created for the bot above
3. Select **Bot** under SETTINGS
4. Click **Add Bot** and then **Yes, do it!**

## Getting an Client ID and Token

1. Head over to the [Discord Developer Portal](https://discord.com/developers/applications)
2. Select the application created for the bot above
3. Select **OAuth2** under SETTINGS and click **Copy** under Client information > CLIENT ID.
4. Select **Bot** under SETTINGS and click **Copy** Under Build-A-Bot > TOKEN.

## Adding Bot to your Server

1. Head over to the [Discord Permissions Calculator](https://discordapi.com/permissions.html#19456)
2. For **Client ID**, paste the Client ID from above
3. Click the resulting URL
4. Select the server to add the bot to and click **Continue**
5. Confirm the permissions (should be Read Messages, Send Messages, and Embed Links) and click **Authorize**
6. Ensure that the Bot has permissions to the RS and Fun channels defined in the Config Vars
