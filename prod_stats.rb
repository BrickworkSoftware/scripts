#!/usr/bin/env ruby

require 'yaml'
require 'uri'
require 'json'
require 'date'
require 'faraday'

@conf = YAML::load_file('config.yml')

scores = {
  'S' => 1,
  'M' => 2,
  'L' => 3,
  'XL' => 5,
  '~' => 0
}

today = Date.today
d = Date.today
if d.cwday == 1
  d -= 7
else
  d -= d.cwday - 1
end
# d -= d.cwday - 1 unless d.cwday == 1
d.strftime('%Y-%m-%d')

conn = Faraday.new(url: 'https://sprint.ly') # create a new Connection with base URL
conn.basic_auth( @conf['sprintly_email'], @conf['sprintly_api_key'])     # set the Authentication header
# resp = conn.get('/api/items/search.json?q=closed:>=2016-05-30 closed:<=2016-06-06 -tag:"false alarm"&facets=tag&product=39361&limit=0')
res = conn.get '/api/items/search.json',
  {
    # :q =>'closed:>=2016-05-30 closed:<=2016-06-06 -tag:"false alarm"',
    :q =>'closed:>='+d.strftime('%Y-%m-%d')+' closed:<='+today.strftime('%Y-%m-%d')+' -tag:"false alarm"',
    :facets => 'tag',
    # :limit => 0,
    :product => 39361
  }

# puts res.body
hash = JSON.parse(res.body)

weight = Hash.new(0)

hash['items'].each do |i|
  # puts i
  i['tags'].each do |t|
    case t
    when "feature request"
      weight['feature request'] += scores[i['score']]
    when "bug"
      weight['bug'] += scores[i['score']]
    when "implementation"
      weight['implementation'] += scores[i['score']]
    when "engineering"
      weight['engineering'] += scores[i['score']]
    when "forward product"
      weight['forward product'] += scores[i['score']]
    end
  end

end

tally = hash['facets']['tag']

puts weight.to_json
puts tally.to_json
