require 'cinch'
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key = "IOo4mv0KW65QOVh4nUYApEdML"
  config.consumer_secret = "9ZiHRxOXu57s6zzFgP3ZkjAGEECqx8cK8DbREb3n6DRWHVe3RP"
  config.access_token = "928490052-9HK80E324fqstddP2t782ciUaKdpPnCLdG4i3vLJ"
  config.access_token_secret = "CY3UZ1uHPUIPekFmfuuaMGwIBfvGea5ueRoCYigLxFR44"
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.phinugamma.org"
    c.channels = ["#murder"]
    c.nick = "jakebot"
  end

  on :message, "hello jakebot" do |m|
    m.reply "Hello, #{m.user.nick}"
  end

  on :message, /^!tweet (.+)/ do |m, tw|
    tweet = client.update tw
    m.reply "It's been tweeted at #{tweet.url}"
  end
end

bot.start


