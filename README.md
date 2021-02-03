# Hades' Star Discord Bot

A simple discord bot I put together for helping to schedule/queue private Red Star runs. Pretty
basic right now with all the configuration done inside the source or (in a few instances) set
via environmental variables.

Currently only running locally. Next step, host it in Heroku!

## Installation

Built on top of Ruby 3, make sure to have it installed first!

```bash
bundle install
```

## Setup

Add the following environmental variables, populating them from you Discord application and bot.

```bash
export R2D2_TOKEN=<your bot token here>
export R2D2_CLIENT_ID=<your application client id here>
```

## Running

```bash
ruby bot.rb
```