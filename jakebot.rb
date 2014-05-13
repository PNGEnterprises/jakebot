require 'cinch'
require 'twitter'
require 'yaml'

affirmatives = [ "Got it!", "Word.", "For sure, yo.", "Fo shizzle." ]
greetings = [ "What up.", "Yo!", "The funk has arrived." ]
bot_dir = File.expand_path "~/.jakebot"
welcome_messages = {}

client = Twitter::REST::Client.new do |config|
  config.consumer_key = "IOo4mv0KW65QOVh4nUYApEdML"
  config.consumer_secret = "9ZiHRxOXu57s6zzFgP3ZkjAGEECqx8cK8DbREb3n6DRWHVe3RP"
  config.access_token = "928490052-9HK80E324fqstddP2t782ciUaKdpPnCLdG4i3vLJ"
  config.access_token_secret = "CY3UZ1uHPUIPekFmfuuaMGwIBfvGea5ueRoCYigLxFR44"
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.phinugamma.org"
    c.channels = ["#bottest"]
    c.nick = "jakebot"
  end

  on :message, "hello jakebot" do |m|
    m.reply "hi #{m.user.nick}"
  end

  on :message, /^!tweet (.+)/ do |m, tw|
    tweet = client.update tw
    m.reply "#{affirmatives.sample} It's been tweeted at #{tweet.url}"
  end

  on :message, /^!welcome (.+)/ do |m, message|
    welcome_messages[m.user.nick] = message
    m.reply "#{affirmatives.sample}"

    # Save the messages
    IO.write("#{bot_dir}/welcome", YAML.dump(welcome_messages))
  end

  on :message, /^(.+)$/ do |m, message|
    # Save the message or update stats w/e
  end

  on :join do |m|
    greeting = greetings.sample

    # Case of bot joining
    if m.user == bot.nick
      m.reply "HELLO EVERYONE! I AM JAKEBOT v0.2"
      return
    end

    m.channel.op(m.user)
    if welcome_messages.key?(m.user.nick)
      m.reply welcome_messages[m.user.nick]
    else
      m.reply greetings.sample
    end
  end
end

# Create the storage directory if it doesn't exist
Dir.mkdir(bot_dir) unless File.exists?(bot_dir)

# Load the saved welcome messages, if they exist
if File.exists?("#{bot_dir}/welcome")
  welcome_messages = YAML.load_file("#{bot_dir}/welcome")
end

# Start the bot
bot.start


