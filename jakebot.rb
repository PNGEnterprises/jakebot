require 'cinch'
require 'twitter'
require 'yaml'

bot_dir = File.expand_path "~/.jakebot"
welcome_messages = {}
phrases = {}
channels = ["#bottest"]
VERSION = '0.2.3.1'

# Create the storage directory if it doesn't exist
Dir.mkdir(bot_dir) unless File.exists?(bot_dir)

if !(File.exists?("#{bot_dir}/keys") and File.exists?("#{bot_dir}/phrases"))
  abort "This bot will not work until files 'phrases' and 'keys' are placed in ~/.jakebot"
end

keys = YAML.load(File.read("#{bot_dir}/keys"))
phrases = YAML.load(File.read("#{bot_dir}/phrases"))

# Load the saved welcome messages, if they exist
if File.exists?("#{bot_dir}/welcome")
  welcome_messages = YAML.load_file("#{bot_dir}/welcome")
end

# Load twitter client
tw_client = Twitter::REST::Client.new do |config|
  tw_keys = keys['twitter']

  config.consumer_key = tw_keys['consumer_key']
  config.consumer_secret = tw_keys['consumer_secret']
  config.access_token = tw_keys['access_token']
  config.access_token_secret = tw_keys['access_token_secret']
end

bot = Cinch::Bot.new do
  # Configure the bot

  configure do |c|
    c.server = "irc.phinugamma.org"
    c.channels = channels
    c.nick = "jakebot"
    c.user = "jakebot"
    c.realname = "Jake Mk II"
  end

  # Register handlers

  on :message, /^(hello|hi) jakebot/ do |m|
    m.reply "#{phrases['greetings'].sample} #{m.user.nick}"
  end

  on :message, /^!tweet (.+)/ do |m, tw|
    tweet = tw_client.update tw
    m.reply "#{phrases['affirmatives'].sample} It's been tweeted at #{tweet.url}"
  end

  on :message, /^!welcome (.+)/ do |m, message|
    welcome_messages[m.user.nick] = message
    m.reply "#{phrases['affirmatives'].sample}"

    # Save the messages
    IO.write("#{bot_dir}/welcome", YAML.dump(welcome_messages))
  end

  on :message, /^(.+)$/ do |m, message|
    # Save the message or update stats w/e
  end

  on :join do |m|
    greeting = phrases['greetings'].sample

    # Case of bot joining
    if m.user == bot.nick
      m.reply "HELLO EVERYONE! I AM JAKEBOT v#{VERSION}"
    else
      m.channel.op(m.user)
      if welcome_messages.key? m.user.nick
        m.reply welcome_messages[m.user.nick]
      else
        m.reply phrases['welcomes'].sample
      end
    end
  end

  on :message, /^!topic ?add (.+)/ do |m, new_topic|
    current_topic = m.channel.topic
    if current_topic.empty? 
      m.channel.topic = new_topic
    else
      m.channel.topic = "#{current_topic} | #{new_topic}"
    end
  end

  on :message, /^!topic ?rem(ove)? (.+)/ do |m, garbage, top|
    # Remove an items from the topic
    
    reg = Regexp.new(top, true) # Case insensitive regexp
    current_topic = m.channel.topic
    topic_segments = current_topic.split(" | ")
    
    topic_segments.each do |t|
      if reg =~ t
        topic_segments.delete(t)
      end
    end
    
    new_topic = topic_segments.join(" | ")
    
    if new_topic.eql? current_topic
      # If the edited topic and new topic are the same, the
      # requested item to delete must not have been found
      m.reply "That's not in the topic" 
    else
      m.channel.topic = new_topic
    end
  end

  # Start timers

  Timer(3 * 59) { # Every ~3 minutes
    if rand < 0.01 # 1% chance
      channels.each do |chan| Channel(chan).send(phrases['jakeisms'].sample) end
    end
  }
end

# Start the bot
bot.start
