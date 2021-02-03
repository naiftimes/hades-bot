require 'bundler/setup'
require 'discordrb'

require_relative 'app/services/red_star_coordinator'

RS_LEVELS = 1..11

bot = Discordrb::Commands::CommandBot.new(
  token: ENV['R2D2_TOKEN'],
  client_id: ENV['R2D2_CLIENT_ID'],
  prefix: '!'
)

RS_LEVELS.each do |level|
  bot.command "rs#{level}".to_sym do |event, *args|
    RedStarCoordinator.call(event, level, *args)
  end
end

bot.run
