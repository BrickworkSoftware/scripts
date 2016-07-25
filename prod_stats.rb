#!/usr/bin/env ruby

require 'yaml'
require 'uri'
require 'json'
require 'date'
require 'faraday'
require 'csv'

@conf = YAML::load_file('config.yml')

scores = {
  'S' => 1,
  'M' => 2,
  'L' => 3,
  'XL' => 5,
  '~' => 0
}

d = Date.today
if d.cwday == 1 # is it Monday?
  d -= 7 # skip to the previous Monday
else
  d -= d.cwday - 1 # skip to the most recent Monday
end

d.strftime('%Y-%m-%d')

dates = [" "]
freq = ["feature request"]
bug = ["bug"]
fprod = ["forward product"]
impl = ["implementation"]
eng = ["engineering"]

conn = Faraday.new(url: 'https://sprint.ly') # create a new Connection with base URL

# using hokey indexes to aid in the bifurcation of arrays for tracking tix and weights
(1..7).each do |i|
  # puts "Stats for "+d.strftime('%Y-%m-%d')+" to "+(d+7).strftime('%Y-%m-%d')

  conn.basic_auth( @conf['sprintly_email'], @conf['sprintly_api_key'])     # set the Authentication header
  # resp = conn.get('/api/items/search.json?q=closed:>=2016-05-30 closed:<=2016-06-06 -tag:"false alarm"&facets=tag&product=39361&limit=0')
  res = conn.get '/api/items/search.json',
    {
      # Range should  include >= Monday
      :q =>'closed:>='+d.strftime('%Y-%m-%d')+' closed:<='+(d+7).strftime('%Y-%m-%d')+' -tag:"false alarm"',
      :facets => 'tag',
      # :limit => 0,
      :product => 39361
    }

  # puts res.body
  hash = JSON.parse(res.body)
  weight = Hash.new(0)
  total_tickets = 0
  total_weights = 0

  hash['items'].each do |i|
    puts "Unscored Ticket: " + i['short_url'] if i['score'] == '~'
    total_tickets += 1
    total_weights += scores[i['score']]
    tag_count = 0
    i['tags'].each do |t|
      case t
      when "feature request"
        weight['feature request'] += scores[i['score']]
        tag_count += 1
      when "bug"
        weight['bug'] += scores[i['score']]
        tag_count += 1
      when "implementation"
        weight['implementation'] += scores[i['score']]
        tag_count += 1
      when "engineering"
        weight['engineering'] += scores[i['score']]
        tag_count += 1
      when "forward product"
        weight['forward product'] += scores[i['score']]
        tag_count += 1
      end
    end
    puts "Multi-counted ticket: #{i['short_url']}" if tag_count > 1
  end

  tally = hash['facets']['tag']

  # puts "Total Tickets: #{total_tickets}"
  # puts tally.to_json
  # puts "Total Weight: #{total_weights}"
  # puts weight.to_json

  def insert_data( arr, iter, tix, wght)
    # dates << d.strftime('%Y-%m-%d') + " wghts"
    # dates.insert(i, d.strftime('%Y-%m-%d') + " tix" )

    # dates.insert(1+i, d.strftime('%Y-%m-%d') + " wghts" )
    # dates.insert(1, d.strftime('%Y-%m-%d') + " tix" )

    arr.insert(1, tix || 0 )
    arr.insert(1+iter, wght || 0 )
    return arr
  end

  dates = insert_data( dates, i, d.strftime('%Y-%m-%d') + " tix", d.strftime('%Y-%m-%d') + " wghts")
  d -= 7 # previous weeks of stats for next iteration

  next if tally.nil?
  freq = insert_data(freq, i, tally['feature request'], weight['feature request'])
  bug = insert_data(bug, i, tally['bug'], weight['bug'])
  fprod = insert_data(fprod, i, tally['forward product'], weight['forward product'])
  impl = insert_data(impl, i, tally['implementation'], weight['implementation'])
  eng = insert_data(eng, i, tally['engineering'], weight['engineering'])

end

puts dates.to_csv
puts fprod.to_csv
puts freq.to_csv
puts impl.to_csv
puts eng.to_csv
puts bug.to_csv
