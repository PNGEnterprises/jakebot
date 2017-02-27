require 'slack-ruby-bot'
require 'twitter'
require 'yaml'

class Jakebot < SlackRubyBot::Bot
  # Initialize everything

  bot_dir = File.expand_path "~/.jakebot"
  welcome_messages = {}
  responses = {}
  phrases = {}
  VERSION = '0.2.6s'

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

  if File.exists? "#{bot_dir}/responses"
    responses = YAML.load_file("#{bot_dir}/responses")
  end

  # Load twitter client

  tw_client = Twitter::REST::Client.new do |config|
    tw_keys = keys['twitter']

    config.consumer_key = tw_keys['consumer_key']
    config.consumer_secret = tw_keys['consumer_secret']
    config.access_token = tw_keys['access_token']
    config.access_token_secret = tw_keys['access_token_secret']
  end

  # Register handlers

  match /^(hello|hi|yo|hey|greetings|howdy|hola|salutations) jakebot/i do |client, data, match| #maybe make a new file for this?
    client.say(channel: data.channel, text: "#{phrases['greetings'].sample} #{data['user']['name']}")
  end

  match /^!tweet (?<tweet_text>.+)/i do |client, data, match|
    tweet = tw_client.update match[:tweet_text]
    client.say(channel: data.channel, text: "#{phrases['affirmatives'].sample} It's been tweeted at #{tweet.url}")
  end


  match /^!kill (?<victim>.+)/i do |client, data, match|
    victim = match[:victim]
    client.say(channel: data.channel, text: "Killing #{victim}")
    sleep 1
    client.say(channel: data.channel, text: "pew pew pew")
    sleep 0.5
    client.say(channel: data.channel, text: "#{victim} is dead")
  end
  
  
  match /^!retard/i do |client, data, match|
    client.say(channel: data.channel, text:"im retarded")
  end

  match /^!respond "(?<trigger>.+)" "(?<response>.+)"/i do |client, data, match|
    trigger = match[:trigger]
    response = match[:response]

    trigger.downcase!

    if !responses.key? trigger
      responses[trigger] = []
    end
    
    responses[trigger].push response

    client.say(channel: data.channel, text: "#{phrases['affirmatives'].sample}")

    IO.write("#{bot_dir}/responses", YAML.dump(responses))
  end

  match /^jakebot (?<message>.+)/i do |client, data, match|
    message = match[:message]
    message.downcase!
    if responses.key? message
      client.say(channel: data.channel, text: responses[message].sample)
    end
  end

  match /jakeism/i do |client, data, match|
    client.say(channel: data.channel, text: phrases['jakeisms'].sample)
  end
end

# Start the bot
Jakebot.run
