#!/usr/bin/env ruby

require 'yaml'
require 'tracker_api'
require 'csv'
require 'prawn'
require 'prawn/icon'

@conf = YAML::load_file('config.yml')

font_type = "Helvetica"
icons = [ 'fa-shopping-bag', 'fa-ticket', 'fa-map-pin', 'fa-rocket',
  'fa-car', 'fa-anchor', 'fa-camera', 'fa-bullhorn', 'fa-bullseye',
  'fa-asterisk', 'fa-bicycle', 'fa-cloud', 'fa-diamond', 'fa-flag',
  'fa-plane', 'fa-cogs', 'fa-magnet', 'fa-paper-plane', 'fa-hashtag',
  'fa-plug', 'fa-shopping-cart', 'fa-moon-o', 'fa-wrench']

client = TrackerApi::Client.new(token: @conf['pivotal_api_key'])
project = client.project(1916005) # dev project
stories = project.stories(filter: 'label:"sprint 5"')
# project = client.project(1917785) # Asiago project
# stories = project.stories(filter: 'label:"asiago_sprint_1"')

icons.shuffle! # don't want to get bored with the icons
card_pic = icons[0]

def gen_card(pdf, icon, story, task, estimate)

end

pdf = Prawn::Document.generate( "cards.pdf", :page_size => [432, 288]) do

  stories.each do |story|
    card_pic = icons.shift
    # puts card_pic
    if (story.tasks.empty?)
      puts "Story with no tasks: #{story.name}"
      # puts story.name
    end
    story.tasks.each do |task|

      # stroke_axis

      /(.+?)( \((\d+h)\))?$/ =~ task.description

      move_down 20
      font(font_type, :size => 12) { text story.name } # story
      move_down 20
      font(font_type, :size => 24, :style => :bold) { text $1 } # task

      if ($3) # have an hours estimate for the task?
        bounding_box([325, 22], :width => 40, :height => 12) do
          font(font_type, :size => 10, :style => :italic) { text $3, :valign => :bottom, :align => :right }
          # stroke_bounds
        end
      end

      bounding_box([330,230], :width => 50, :height => 50) do
        icon card_pic, size:30
        # stroke_bounds
      end

      start_new_page
    end
  end
end
