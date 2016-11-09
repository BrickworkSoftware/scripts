#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'csv'
require 'faraday'

@conf = YAML::load_file('config.yml')

csv_file, domain, api_key, *the_rest = ARGV

conn = Faraday.new(url: "https://#{domain}.brickworksoftware.com") # create a new Connection with base URL

# {
#     "special_hour": {
#         "date": "2016-06-12",
#         "start_time": "9am",
#         "display_name": "Renovations",
#         "end_time": "9pm",
#         "closed": false,
#         "day_of_week": 0
#     }
# }

CSV.foreach(csv_file) do |row|
  puts row.to_json
  next if row[0] == "store_number" # skip header line

  hour = {
    "special_hour"=> {
      "date"=> row[2],
      "start_time"=> row[3],
      "display_name"=> row[5],
      "end_time"=> row[4],
      "closed"=> row[6],
      "day_of_week"=> 0 # why the fuck do I need day of the week?
    }
  }

  puts hour.to_json
  exit

  url = "/api/v3/admin/stores/#{row[0]}/special_hours"
  puts url
  res = conn_c.post do |req|
    req.url url
    req.params['api_key'] = api_key
    req.params['store_number'] = "true"
    req.headers['Content-Type'] = 'application/json'
    req.body = hour.to_json
  end

  puts res.status
  puts res.body

  # puts res.status
  #sprintly = JSON.parse(res.body)
end
