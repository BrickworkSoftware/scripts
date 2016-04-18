#!/usr/bin/env ruby

require 'asana'
require 'yaml'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

conf = YAML::load_file('config.yaml')

# pop these args off so ARGF doesn't try
# to read them as files
override_tags = []
until ARGV.empty? do
  override_tags.push(ARGV.shift)
end

# using the 'tix' hash for uniqueness to make sure I don't dupe tickets
# in a single run
tix = {}
re = /(https?:\/\/app.asana.com\/\d\/\d+\/(\d+)(\/f)?)/
ARGF.each { |line|
  if matches = line.scan(re)
    matches.each{ |match|
      tix[match[1]] = match[0]
    }
  end
}

client = Asana::Client.new do |c|
  c.authentication :access_token, conf['asana_token']
end

tix.keys.each { |aID|
  task = Asana::Task.find_by_id(client, aID)

  tags = ""
  task.tags.each { |t|
    tags << t.name << ","
  }
  override_tags.each { |t|
    tags << t << ","
  }
  tags.chop!

  # attachments = []
  # Asana::Attachment.find_by_task(client, task: task.id).each { |a|
  #   #puts a
  #   attachments.push(Asana::Attachment.find_by_id(client, a.id))
  #   #puts attachments
  # }
  # puts "Attachments #{attachments}"

  @toSend = {
    "type" => "task",
    "status" => "backlog",
    "title" => task.name,
    "description" => task.notes + "\n\nSource: #{tix[aID]}",
    "tags" => tags
  }#.to_json

  # uri = URI.parse("https://sprint.ly/api/user/whoami.json")
  uri = URI.parse("https://sprint.ly/api/products/#{conf['sprintly_product_id']}/items.json")
  # uri = URI.parse("https://httpbin.org/post")
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true
  # req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
  req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/x-www-form-urlencoded'})
  # req['foo'] = 'bar'
  req.basic_auth conf['sprintly_email'], conf['sprintly_api_key']
  #req.body = "[ #{@toSend} ]"
  req.body = URI.encode_www_form(@toSend)
  #puts req.body
  res = https.request(req)

  if res.code == "200"
    puts "#{tix[aID]} => #{JSON.parse(res.body)['short_url']}"
  else
    puts "Response #{res.code} #{res.message}: #{res.body}"
  end
}
