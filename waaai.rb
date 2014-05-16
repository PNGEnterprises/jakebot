require 'net/http'
require 'uri'

class Waaai
   @@api_endpoint = 'api.waa.ai'

   def self.shorten url
     esc_url = URI.encode("/?url=#{url}")
     Net::HTTP.get(@@api_endpoint, esc_url)
   end
end
