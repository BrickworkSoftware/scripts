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

def s2c_story(sprintly_item)
  item = {
    external_id: "#{sprintly_item['number']}",
    updated_at: sprintly_item['last_modified'],
    created_at: sprintly_item['created_at'],
    story_type: @type_translation[sprintly_item['type']],
    estimate: @estimate_translation[sprintly_item['score']],
    workflow_state_id: @state_translation[sprintly_item['status']],
    name: sprintly_item['title'],
    description: "#{sprintly_item['description']}\n\n\n#{sprintly_item['short_url']}",
    project_id: @conf['clubhouse_project_id'],
    tasks: []
  }

  return item
end

def s2c_task(sprintly_item)
  item = {
    complete: (sprintly_item['status'] == "completed" || sprintly_item['status'] == "accepted"),
    created_at: sprintly_item['created_at'],
    # description: sprintly_item['description'],
    description: sprintly_item['title'],
    external_id: "#{sprintly_item['number']}",
    updated_at: sprintly_item['last_modified']
  }

  return item
end

def add_s2c( ch_table, sprintly_item)
  if sprintly_item['parent'].nil?
    ch_table[sprintly_item['number']] = s2c_story(sprintly_item)
  else
    if ch_table[sprintly_item['parent']['number']].nil?
      ch_table[sprintly_item['parent']['number']] = s2c_story(sprintly_item['parent'])
    end
    ch_table[sprintly_item['parent']['number']][:tasks] << s2c_task(sprintly_item)
  end

  return ch_table
end

conn_c = Faraday.new(url: 'https://api.clubhouse.io') # create a new Connection with base URL

conn_s = Faraday.new(url: 'https://sprint.ly') # create a new Connection with base URL
conn_s.basic_auth( @conf['sprintly_email'], @conf['sprintly_api_key'])

limit = 500
# limit = 10
iteration = 0
table = {}

loop do

  res = conn_s.get "/api/products/#{@conf['sprintly_product_id']}/items.json",
    {
      :children => true,
      :limit => limit,
      :offset => iteration * limit,
      :order_by => 'oldest',
      # :status => 'someday,backlog,in-progress,completed,accepted'
      :status => 'completed'
    }

  sprintly = JSON.parse(res.body)

  # if no longer getting back items from the sprintly api, break
  break if sprintly.empty?

  sprintly.each do |item|

    table = add_s2c(table, item)

    # url = "/api/v1/stories"
    # puts url
    # res = conn_c.post do |req|
    #   req.url url
    #   req.params['token'] = @conf['clubhouse_api_token']
    #   req.headers['Content-Type'] = 'application/json'
    #   req.body = ch_item.to_json
    # end
    #
    # puts res.body
  end

  iteration += 1
end

puts table.values.to_json
