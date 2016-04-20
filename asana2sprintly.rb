#!/usr/bin/env ruby

require 'asana'
require 'yaml'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

@conf = YAML::load_file('config.yml')

def get_attachments_by_id( client, id)
  files = []
  Asana::Attachment.find_by_task(client, task: id).each { |a|
    files.push(Asana::Attachment.find_by_id(client, a.id))
  }
  return files
end

def create_sprintly_ticket( type, status, name, desc, tags, asana_url)
  ticket = {
    "type" => type,
    "status" => status,
    "title" => name,
    "description" => desc + "\n\nSource: #{asana_url}",
    "tags" => tags
  }#.to_json

  # uri = URI.parse("https://sprint.ly/api/user/whoami.json")
  uri = URI.parse("https://sprint.ly/api/products/#{@conf['sprintly_product_id']}/items.json")
  # uri = URI.parse("https://httpbin.org/post")
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true
  # req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
  req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/x-www-form-urlencoded'})
  # req['foo'] = 'bar'
  req.basic_auth @conf['sprintly_email'], @conf['sprintly_api_key']
  #req.body = "[ #{@toSend} ]"
  req.body = URI.encode_www_form(ticket)
  #puts req.body
  return https.request(req)
end

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

# Asana module docs: http://www.rubydoc.info/github/Asana/ruby-asana/master/Asana
client = Asana::Client.new do |c|
  c.authentication :access_token, @conf['asana_token']
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

  attachments = get_attachments_by_id( client, task.id)

  res = create_sprintly_ticket( "task", "backlog", task.name, task.notes, tags, tix[aID])

  if res.code == "200"
    puts "#{tix[aID]} => #{JSON.parse(res.body)['short_url']}"
  else
    puts "Response #{res.code} #{res.message}: #{res.body}"
  end
}
