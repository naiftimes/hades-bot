class RedStarCoordinator
  attr_reader :event, :level, :bot, :role, :args

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

  def initialize(event, level, *args)
    @event = event
    @level = level
    @bot = event.server.bot
    @role = event.server.roles.find { |role| role.name == "RS#{level}" }
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
    when 'clear'
      clear
    end
  end

  def join
    puts
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

  class << self
    def call(event, level, *args)
      new(event, level, *args).call
    end

    def queue
      @queue ||= {}
    end

    def attendees(level)
      queue[level] ||= []
    end

    def add_attendee(level, user)
      attendees(level) << user unless attendees(level).include?(user)
    end

    def remove_attendee(level, user)
      attendees(level).delete(user)
    end

    def reset_attendees(level)
      queue[level] = []
      nil
    end

    def messages
      @messages ||= {}
    end

    def message(level)
      messages[level]
    end

    def store_message(level, message)
      messages[level] = message
    end

    def remove_message(level)
      messages.delete(level)
    end
  end

private

  def attendees
    self.class.attendees(level)
  end

  def add_attendee
    self.class.add_attendee(level, event.user.mention)
  end

  def remove_attendee
    self.class.remove_attendee(level, event.user.mention)
  end

  def reset_attendees
    self.class.reset_attendees(level)
  end

  def store_message(message)
    self.class.store_message(level, message)
  end

  def delete_last_message
    return unless (message = self.class.message(level))

    message.delete
    self.class.remove_message(level)
  end

  def send_go_message
    event.send_embed do |embed|
      embed.color = '#FF0000'
      embed.title = "Red Star #{level} GO!"
      embed.thumbnail = thumbnail
      embed.description = GO_MESSAGES.sample
      embed.fields << attendees_field
      embed.footer = footer
    end
    # event << "#{attendees.join(', ')} RS#{level} is a go!"
  end

  def send_status_message
    message = event.send_embed do |embed|
      embed.color = '#FF0000'
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

  def send_clear_message
    event << "Queue cleared for RS#{level}"
  end

  def thumbnail
    Discordrb::Webhooks::EmbedThumbnail.new(
      url: 'https://cdn.discordapp.com/attachments/767039274255777822/806638064566009887/rss11_1.png'
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
end
