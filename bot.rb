require 'bundler/setup'
require 'discordrb'
require 'faker'
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

rs_channels = ENV['R2D2_RS_CHANNELS'].split(',').map(&:to_i)
fun_channels = ENV['R2D2_FUN_CHANNELS'].split(',').map(&:to_i)

RS_LEVELS.each do |level|
  bot.command "rs#{level}".to_sym do |event, *args|
    break unless rs_channels.include?(event.channel.id)

    RedStarCoordinator.call(redis, event, level, *args)
  end

  bot.command :turnip do |event|
    break unless fun_channels.include?(event.channel.id)

    event << Faker::Quote.most_interesting_man_in_the_world
  end
end

bot.run
