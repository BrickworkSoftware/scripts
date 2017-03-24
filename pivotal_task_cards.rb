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
  opts.on("-p", "--project PROJECT", [:dev, :asiago, :product], "REQD: 'dev', 'asiago', 'product'") do |p|
    options[:project] = p
  end
  opts.on("-l", "--label LABEL", "Pivotal label to select stories") do |l|
    options[:label] = l
  end
  opts.on("-d", "--story_id STORY_ID", "ID of a particular story") do |s|
    if /^#?(\d+)$/ =~ s
      options[:story_id] = $1
    end
  end
  opts.on("-i", "--corner_icon ICON", "Corner icon") do |i|
    options[:corner_icon] = i
  end
  opts.on("-S", "--storycards", "Only generate story cards") do |s|
    options[:story_cards] = s
  end
  # No argument, shows at tail.  This will print an options summary.
  # Try it and see!
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end
op.parse!

if options[:project].nil? #|| options[:label].nil?
  puts "Project is a required parameter\n\n"
  puts op.help()
  exit
end

if options[:project] == :asiago
  pid = 1917785 # asiago project
elsif options[:project] == :product
  pid = 1914871 # product project
else
  pid = 1916005 # dev project
end

icons = [ 'fi-marker', 'fi-heart', 'fi-star', 'fi-check', 'fi-widget',
  'fi-paperclip', 'fi-lock', 'fi-magnifying-glass', 'fi-cloud',
  'fi-wrench', 'fi-flag', 'fi-clock', 'fi-eye', 'fi-camera', 'fi-mail',
  'fi-telephone', 'fi-megaphone', 'fi-web', 'fi-shopping-cart','fi-compass',
  'fi-lightbulb', 'fi-asterisk', 'fi-at-sign', 'fi-key', 'fi-ticket',
  'fi-anchor', 'fi-puzzle', 'fi-mountains', 'fi-trees',
  'fi-crown', 'fi-target', 'fi-die-six', 'fi-map']

client = TrackerApi::Client.new(token: @conf['pivotal_api_key'])
# project = client.project(1916005) # dev project
# stories = project.stories(filter: 'label:"sprint 5"')
# project = client.project(1917785) # Asiago project
# stories = project.stories(filter: 'label:"asiago_sprint_1"')

project = client.project(pid)
# stories = project.stories(filter: "label:\"#{options[:label]}\"")
stories = []
if options[:label]
  stories += project.stories(filter: "label:\"#{options[:label]}\"", fields: ':default,owners,tasks')
end
if options[:story_id]
  stories << project.story(options[:story_id].to_i, fields: ':default,owners,tasks')
end

puts "Generating cards for #{stories.length} stories"

icons.shuffle! # don't want to get bored with the icons
card_pic = icons[0]

def gen_card(pdf, icon, story, task, estimate, type, owner)
  font_type = "Helvetica"

  # pdf.stroke_axis

  pdf.font(font_type, :size => 12) {
    pdf.text_box story,
      :at => [0,210],
      :width => 340,
      :overflow => :shrink_to_fit,
      :min_font_size => 6
  } # story

  if type == 'bug'
    pdf.move_down 50
    pdf.transparent(0.15) do
      pdf.fill_color "F44242" # red
      pdf.icon 'fa-bug', size:150, :valign => :middle, :align => :center
    end
  end

  # pdf.font(font_type, :size => 28, :style => :bold) { pdf.text task } # task
  pdf.font(font_type, :size => 28, :style => :bold) {
    pdf.text_box task,
      :at => [0, 170],
      :overflow => :shrink_to_fit,
      :min_font_size => 12
    # pdf.text task
  }


  if (estimate) # have an hours estimate for the task?
    pdf.bounding_box([325, 5], :width => 40, :height => 12) do
      pdf.font(font_type, :size => 10, :style => :italic) { pdf.text estimate, :valign => :bottom, :align => :right }
      # pdf.stroke_bounds
    end
  end

  if (owner) # have an owner for the task?
    pdf.bounding_box([-10, 10], :width => 70, :height => 22) do
      pdf.font(font_type, :size => 16, :style => :bold) { pdf.text owner, :valign => :bottom, :align => :left }
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
  i = 0
  stories.each do |story|
    card_pic = options[:corner_icon] || icons.shift
    # puts card_pic
    pts = story.attributes[:estimate].to_i
    if (pts == 1)
      pts = "[#{story.attributes[:estimate].to_i} pt]"
    else
      pts = "[#{story.attributes[:estimate].to_i} pts]"
    end
    initials = nil
    if !story.owners.empty?
      initials = story.owners[0].initials # not bothering with mult-owned stories
    end
    i += 1
    story_ord = "(#{i}/#{stories.length})"
    if (story.tasks.empty? || options[:story_cards])
      puts "Story #{story_ord} - Only Story Card:\n  #{story.name}"
      gen_card(pdf, card_pic, "#{ord} #{story.name} #{pts}", story.name, nil, story.story_type, initials)
      next
    end
    puts "Story #{story_ord} with #{story.tasks.length} Tasks:\n  #{story.name}"

    j = 0
    story.tasks.each do |task|
      j += 1

      # /(.+?)( \((\d+h)\))?$/ =~ task.description
      /^(.+?)( \((\d+h)\))?( ?\[.*\])?$/ =~ task.description

      gen_card( pdf, card_pic, "#{story.name} #{pts}", "(#{j}/#{story.tasks.length}) #{$1}", $3, story.story_type, initials)

      # puts "    Task Card..."
    end
  end
end
