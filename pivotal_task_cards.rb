#!/usr/bin/env ruby

require 'yaml'
require 'tracker_api'
require 'csv'
require 'prawn'
require 'prawn/icon'

@conf = YAML::load_file('config.yml')

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
  font_type = "Helvetica"

  # pdf.stroke_axis

  pdf.move_down 20
  pdf.font(font_type, :size => 12) { pdf.text story } # story
  pdf.move_down 20
  pdf.font(font_type, :size => 24, :style => :bold) { pdf.text task } # task

  if (estimate) # have an hours estimate for the task?
    pdf.bounding_box([325, 22], :width => 40, :height => 12) do
      pdf.font(font_type, :size => 10, :style => :italic) { pdf.text estimate, :valign => :bottom, :align => :right }
      # stroke_bounds
    end
  end

  pdf.bounding_box([330,230], :width => 50, :height => 50) do
    pdf.icon icon, size:30
    # stroke_bounds
  end

  pdf.start_new_page
end

Prawn::Document.generate( "cards.pdf", :page_size => [432, 288]) do |pdf|

  stories.each do |story|
    card_pic = icons.shift
    # puts card_pic
    if (story.tasks.empty?)
      puts "Story with no tasks: #{story.name}"
      gen_card(pdf, card_pic, story.name, story.name, nil)
    end
    story.tasks.each do |task|

      /(.+?)( \((\d+h)\))?$/ =~ task.description

      gen_card( pdf, card_pic, story.name, $1, $3)

    end
  end
end
