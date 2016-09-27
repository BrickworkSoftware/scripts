#!/usr/bin/env ruby

require 'yaml'
require 'faraday'
require 'json'

@conf = YAML::load_file('config.yml')

@estimate_translation = {
  "~" => 0,
  "S" => 1,
  "M" => 2,
  "L" => 3,
  "XL" => 4
}
@estimate_translation.default = "**UNKNOWN ESTIMATE**"

@type_translation = {
  "defect" => "bug",
  "task" => "chore",
  "story" => "feature",
  "test" => "chore"
}
@type_translation.default = "**UNKNOWN TYPE**"

@state_translation = {
  "accepted" => 500000016,
  "backlog" => 500000011,
  "in-progress" => 500000015,
  "completed" => 500000010,
  "someday" => 500000014
}
@state_translation.default = "**UNKNOWN STATE**"

def s2c(sprintly_item)
  item = {
    external_id: "#{sprintly_item['number']}",
    updated_at: sprintly_item['last_modified'],
    created_at: sprintly_item['created_at'],
    story_type: @type_translation[sprintly_item['type']],
    estimate: @estimate_translation[sprintly_item['score']],
    workflow_state_id: @state_translation[sprintly_item['status']],
    name: sprintly_item['title'],
    description: sprintly_item['description'],
    project_id: @conf['clubhouse_project_id']
  }

  return item
end

def add_s2c( ch_table, sprintly_item)
  if sprintly_item['parent'].nil?

  else

  end

  ch_item = {
    external_id: "#{sprintly_item['number']}",
    updated_at: sprintly_item['last_modified'],
    created_at: sprintly_item['created_at'],
    story_type: @type_translation[sprintly_item['type']],
    estimate: @estimate_translation[sprintly_item['score']],
    workflow_state_id: @state_translation[sprintly_item['status']],
    name: sprintly_item['title'],
    description: sprintly_item['description'],
    project_id: @conf['clubhouse_project_id']
  }

  return ch_table
end

conn_c = Faraday.new(url: 'https://api.clubhouse.io') # create a new Connection with base URL

conn_s = Faraday.new(url: 'https://sprint.ly') # create a new Connection with base URL
conn_s.basic_auth( @conf['sprintly_email'], @conf['sprintly_api_key'])

res = conn_s.get "/api/products/#{@conf['sprintly_product_id']}/items.json",
  {
    # :children => true,
    :status => 'backlog,in-progress'
  }

# puts res.body
sprintly = JSON.parse(res.body)

# line_num=0

table = {}
sprintly.each do |item|
  puts item.to_json

  ch_item = {
    external_id: "#{item['number']}",
    updated_at: item['last_modified'],
    created_at: item['created_at'],
    story_type: type_translation[item['type']],
    estimate: estimate_translation[item['score']],
    workflow_state_id: state_translation[item['status']],
    name: item['title'],
    description: item['description'],
    project_id: @conf['clubhouse_project_id']
  }

  puts ch_item.to_json

  #next
  #exit

  url = "/api/v1/stories"
  puts url
  res = conn_c.post do |req|
    req.url url
    req.params['token'] = @conf['clubhouse_api_token']
    req.headers['Content-Type'] = 'application/json'
    req.body = ch_item.to_json
  end

  puts res.body
end
