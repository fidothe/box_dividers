#!/usr/bin/env ruby

require 'prawn'
require 'pathname'

USAGE = <<-EOS
#{$0} width height /path/to/output.pdf
EOS

BaseDir = Pathname.new(Dir.pwd)

width, height, output  = ARGV[0..2]
[['width', width], ['height', height], ['output', output]].each do |name, value|
  raise ArgumentError, "You must supply a #{name} argument!" if value.nil?
end

class Divider
  include Prawn::View

  FULL_WIDTH = 10

  attr_reader :width, :height

  def initialize(width, height)
    @width, @height = width, height
  end

  def draw_divider
    path = top_divider_path
    first_point = path.shift
    stroke do
      move_to *first_point
      path.each do |point|
        line_to *point
      end
      line_to *first_point
    end
  end

  def top_divider_path
    points = []

    points = left_full_height_end_path(0, 1.5 + mm_height)
    points = points + top_unit_path(*points.last)
    (width - 1).times do |n|
      p points
      points = points + top_slot_path(*points.last)
      p points
      points = points + top_unit_path(*points.last)
    end
    points = points + right_full_height_end_path(*points.last)
    points
  end

  def mm_height
    height * 38
  end

  def mm_width
    width * 38
  end

  def top_unit_path(x, y)
    points = []
    tab_start_x = x + 15.2
    points << [tab_start_x, y]
    points = points + tab_path(tab_start_x, y)
    points << [x + 38.4, y]
    points
  end

  def tab_path(x, y)
    points = []
    tab_bottom_y = y - 1.5
    tab_right_x = x + 8
    points << [x, tab_bottom_y]
    points << [tab_right_x, tab_bottom_y]
    points << [tab_right_x, y]
    points
  end

  def top_slot_path(x, y)
    points = []
    slot_top_y = y + (mm_height / 2)
    slot_right_x = x + 3.6
    points << [x, slot_top_y]
    points << [slot_right_x, slot_top_y]
    points << [slot_right_x, y]
    points
  end

  def left_full_height_end_path(x, y)
    points = []
    bottom_y = y - mm_height

    points << [x, y]
    points << [x, bottom_y]
    points << [x + 2, bottom_y]
    points
  end

  def right_full_height_end_path(x, y)
    points = []
    top_y = y + mm_height

    points << [x, top_y]
    points << [x - 2, top_y]
    points
  end

  def left_half_height_end(x, y)
  end

  def right_half_height_end(x, y)
  end
end

divider = Divider.new(Integer(width, 10), Integer(height, 10))
divider.draw_divider
divider.save_as(BaseDir.join(output))
