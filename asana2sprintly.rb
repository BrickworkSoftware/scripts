#!/usr/bin/env ruby

require 'asana'
require 'yaml'
require 'uri'
require 'net/http'
require 'net/https'

conf = YAML::load_file('config.yaml')

# puts conf
# puts "Asana Token: #{conf['asana_token']}"
# puts "Sprintly Key: #{conf['sprintly_api_key']}"
# puts "Sprintly Email: #{conf['sprintly_email']}"

client = Asana::Client.new do |c|
  c.authentication :access_token, conf['asana_token']
end

#client.workspaces.find_all.first

# brickwork workspace
#workspace = client.workspaces.find_by_id(15547030788476)

task = Asana::Task.find_by_id(client, '112974848331541')
# puts task.name
# puts task.notes
# puts task.tags

tags = ""
task.tags.each { |t|
  tags << t.name << ","
}
tags.chop!

# puts task.id
#
# puts task

# attachments = []
# Asana::Attachment.find_by_task(client, task: task.id).each { |a|
#   #puts a
#   attachments.push(Asana::Attachment.find_by_id(client, a.id))
#   #puts attachments
# }
# puts "Attachments #{attachments}"

@toSend = {
  "type" => "task",
  "title" => task.name,
  "description" => task.notes,
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
puts req.body
res = https.request(req)
puts "Response #{res.code} #{res.message}: #{res.body}"
