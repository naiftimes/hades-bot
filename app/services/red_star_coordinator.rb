class RedStarCoordinator
  attr_reader :redis, :event, :level, :args

  GO_MESSAGES = [
    "Oh no, I smell Turnip's voodoo on this one.",
    'Play nice now kids.',
    'Keel *ALL* teh cerbs!!1!',
    'I fell in love with you the moment you stepped into my sector *-Ints*',
    "Watch out, don't get Naifed!",
    "Can't you just leave us alone? *-Cerbs*",
    'Can I get some of dat croid?',
    'Turnips are tubers.',
    "Technically you're about to do some pillaging.",
    "Did you know Aziz's favorite croid comes from RS4?",
    'Turnip looks like a hobbit IRL.'
  ].freeze

  def initialize(redis, event, level, *args)
    @redis = redis
    @event = event
    @level = level
    @args = args
  end

  def call
    case args[0]
    when nil, 'join'
      join
    when 'leave'
      leave
    when 'go'
      go
    when 'status'
      status
    when 'clear', 'cancel'
      clear
    when 'help'
      help
    end
  end

  def join
    add_attendee
    delete_last_message
    if attendees.count >= 4
      send_go_message
      reset_attendees
    else
      send_status_message
    end
  end

  def leave
    remove_attendee
    delete_last_message
    if attendees.count.positive?
      send_status_message
    else
      send_clear_message
    end
  end

  def go
    delete_last_message
    send_go_message
    reset_attendees
  end

  def status
    delete_last_message
    send_status_message
  end

  def clear
    delete_last_message
    send_clear_message
    reset_attendees
  end

  def help
    event << "__Red Star #{level} Help__"
    event << "`!rs#{level}` Join the queue (auto-starts when the 4th attendee joins)."
    event << "`!rs#{level} leave` Leave the queue."
    event << "`!rs#{level} go` Start with less than 4 attendees."
    event << "`!rs#{level} status` Status of the queue."
    event << "`!rs#{level} cancel` Cancel the queue."
  end

  class << self
    def call(redis, event, level, *args)
      new(redis, event, level, *args).call
    end
  end

private

  # MESSAGES
  ##

  def send_status_message
    message = event.send_embed do |embed|
      embed.color = '#9D2000'
      embed.title = "Red Star #{level}"
      embed.thumbnail = thumbnail
      embed.description = "Type `!rs#{level}` to join the queue"
      embed.fields << attendees_field
      embed.fields << queue_field
      embed.fields << invited_field
      embed.footer = footer
    end
    store_message(message)
  end

  def send_go_message
    event.send_embed do |embed|
      embed.color = '#9D2000'
      embed.title = "Red Star #{level} GO!"
      embed.thumbnail = thumbnail
      embed.description = GO_MESSAGES.sample
      embed.fields << attendees_field
      embed.footer = footer
    end
  end

  def send_clear_message
    event << "Queue cleared for RS#{level}"
  end

  # MESSAGE PARTS
  ##

  def thumbnail
    url = ENV.fetch('R2D2_IMAGES_URL', 'https://raw.githubusercontent.com/wamonroe/hades-bot/main/app/images')
             .delete_prefix!('/')
    Discordrb::Webhooks::EmbedThumbnail.new(
      url: "#{url}/rs#{level}.png"
    )
  end

  def attendees_field
    Discordrb::Webhooks::EmbedField.new(
      name: 'Attendees',
      value: attendees.any? ? attendees.join(', ') : '*none*',
      inline: true
    )
  end

  def queue_field
    Discordrb::Webhooks::EmbedField.new(
      name: 'Queue',
      value: "#{attendees.count}/4",
      inline: true
    )
  end

  def invited_field
    Discordrb::Webhooks::EmbedField.new(
      name: 'Invited',
      value: role.nil? ? "RS#{level}" : "#{role.mention} (#{role.members.count} players)",
      inline: true
    )
  end

  def footer
    Discordrb::Webhooks::EmbedFooter.new(
      text: 'Powered by R2D2 | 4 ABY',
      icon_url: bot.avatar_url
    )
  end

  # PERSISTENCE
  ##

  def redis_key(name)
    "rs#{level}_#{name}"
  end

  def attendees
    if (raw = redis.get redis_key(:attendees))
      JSON.parse(raw)
    else
      []
    end
  rescue StandardError
    []
  end

  def add_attendee
    return if attendees.include? user

    redis.set redis_key(:attendees), (attendees + [user]).to_json
    nil
  end

  def remove_attendee
    return unless attendees.include? user

    redis.set redis_key(:attendees), (attendees - [user]).to_json
    nil
  end

  def reset_attendees
    redis.set redis_key(:attendees), [].to_json
    nil
  end

  def last_message_id
    redis.get redis_key(:last_message_id)
  end

  def store_message(message)
    redis.set redis_key(:last_message_id), message.id
    nil
  end

  def delete_last_message
    return unless last_message_id

    event.channel.delete_message(last_message_id)
    redis.del redis_key(:last_message_id)
    nil
  end

  # HELPERS
  ##

  def bot
    @bot ||= event.server.bot
  end

  def role
    @role ||= event.server.roles.find { |role| role.name == "RS#{level}" }
  end

  def user
    @user ||= event.user.mention
  end
end
