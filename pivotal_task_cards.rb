#!/usr/bin/env ruby

require 'yaml'
require 'tracker_api'
require 'prawn'
require 'prawn/icon'
require 'optparse'

@conf = YAML::load_file('config.yml')

options = {}
op = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.separator ""
  opts.separator "Specific options:"
  opts.on("-p", "--project PROJECT", [:dev, :asiago], "Select Pivotal project (dev, asiago)") do |p|
    options[:project] = p
  end
  opts.on("-l", "--label LABEL", "Pivotal label to select stories") do |l|
    options[:label] = l
  end
  # No argument, shows at tail.  This will print an options summary.
  # Try it and see!
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end
op.parse!

if options[:project].nil? || options[:label].nil?
  puts "Missing required parameters\n\n"
  puts op.help()
  exit
end

if options[:project] == "asiago"
  pid = 1917785
else
  pid = 1916005
end

icons = [ 'fi-marker', 'fi-heart', 'fi-star', 'fi-check', 'fi-widget',
  'fi-paperclip', 'fi-lock', 'fi-magnifying-glass', 'fi-lock', 'fi-cloud',
  'fi-wrench', 'fi-flag', 'fi-clock', 'fi-eye', 'fi-camera', 'fi-mail',
  'fi-telephone', 'fi-megaphone', 'fi-web', 'fi-shopping-cart','fi-compass',
  'fi-lightbulb', 'fi-asterisk', 'fi-at-sign', 'fi-key', 'fi-ticket',
  'fi-anchor', 'fi-puzzle', 'fi-mountains', 'fi-trees', 'fi-mountains',
  'fi-crown', 'fi-target', 'fi-die-six', 'fi-map']

client = TrackerApi::Client.new(token: @conf['pivotal_api_key'])
# project = client.project(1916005) # dev project
# stories = project.stories(filter: 'label:"sprint 5"')
# project = client.project(1917785) # Asiago project
# stories = project.stories(filter: 'label:"asiago_sprint_1"')

project = client.project(pid)
stories = project.stories(filter: "label:\"#{options[:label]}\"")

icons.shuffle! # don't want to get bored with the icons
card_pic = icons[0]

def gen_card(pdf, icon, story, task, estimate)
  font_type = "Helvetica"

  # pdf.stroke_axis

  pdf.move_down 20
  pdf.font(font_type, :size => 12) { pdf.text story } # story
  pdf.move_down 20
  pdf.font(font_type, :size => 28, :style => :bold) { pdf.text task } # task

  if (estimate) # have an hours estimate for the task?
    pdf.bounding_box([325, 22], :width => 40, :height => 12) do
      pdf.font(font_type, :size => 10, :style => :italic) { pdf.text estimate, :valign => :bottom, :align => :right }
      # pdf.stroke_bounds
    end
  end

  pdf.bounding_box([340,245], :width => 50, :height => 50) do
    pdf.icon icon, size:50, :valign => :middle, :align => :center
    # pdf.stroke_bounds
  end

  pdf.start_new_page
end

Prawn::Document.generate( "cards.pdf", :page_size => [432, 288]) do |pdf|

  stories.each do |story|
    card_pic = icons.shift
    # puts card_pic
    pts = story.attributes[:estimate].to_i
    if (pts == 1)
      pts = " [#{story.attributes[:estimate].to_i} pt]"
    else
      pts = " [#{story.attributes[:estimate].to_i} pts]"
    end
    if (story.tasks.empty?)
      puts "Story with no tasks: #{story.name}"
      gen_card(pdf, card_pic, story.name + pts, story.name, nil)
    end
    story.tasks.each do |task|

      /(.+?)( \((\d+h)\))?$/ =~ task.description

      gen_card( pdf, card_pic, story.name + pts, $1, $3)

    end
  end
end
