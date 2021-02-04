require 'bundler/setup'
require 'discordrb'
require 'redis'

require_relative 'app/services/red_star_coordinator'

RS_LEVELS = 4..11

redis = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379')
)

bot = Discordrb::Commands::CommandBot.new(
  token: ENV['R2D2_TOKEN'],
  client_id: ENV['R2D2_CLIENT_ID'],
  prefix: '!'
)

channels = ENV['R2D2_CHANNELS'].split(',').map(&:to_i)

RS_LEVELS.each do |level|
  bot.command "rs#{level}".to_sym do |event, *args|
    RedStarCoordinator.call(redis, event, level, *args) if channels.include?(event.channel.id)
  end
end

bot.run
