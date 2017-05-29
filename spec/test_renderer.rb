require 'box_dividers/renderer'
require 'box_dividers/vector'
require 'box_dividers/point'
require 'box_dividers/sheet'
require 'box_dividers/bounding_box'
require 'box_dividers/arc_builder'

class TestRenderer
  attr_reader :paths, :reference_paths, :margin

  def initialize(opts = {})
    @paths = opts.fetch(:paths)
    @reference_paths = opts.fetch(:reference_paths, [])
    @margin = opts.fetch(:margin, 24)
    @overlay = opts.fetch(:overlay, true)
  end

  def render(name)
    BoxDividers::Renderer.render_to_file(sheet, "#{name}.pdf")
  end

  def sheet
    BoxDividers::Sheet.new(width: width, height: height, lower_left: BoxDividers::Point.new(20,20), containers: [bbox])
  end

  def width
    @width ||= untranslated_bbox.width + margin
  end

  def height
    @height ||= untranslated_bbox.height + margin
  end

  def bbox
    @bbox ||= untranslated_bbox.translate(BoxDividers::Vector.translation_between(untranslated_bbox.centre, sheet_centre))
  end

  def untranslated_bbox
    @untranslated_bbox ||= BoxDividers::BoundingBox.new(*containers)
  end

  def sheet_centre
    BoxDividers::Point.new(width/2, height/2)
  end

  def containers
    @containers ||= paths.map { |path|
      paths_to_render = [path]
      if overlay?
        paths_to_render.concat(order_overlay(path, increments: 0.5, min_radius: 2))
      end
      BoxDividers::BoundingBox.new(*paths_to_render)
    } + reference_paths
  end

  def overlay?
    @overlay
  end

  def order_overlay(path, opts = {})
    increments = opts.fetch(:increments, 1)
    min_radius = opts.fetch(:min_radius,  5)
    overlay_paths = path.points.each_with_index.flat_map { |point, i|
      circle_paths = (i + 1).times.map { |n|
        radius = min_radius + increments * (n - 1)
        path = BoxDividers::ArcBuilder.degrees(angle: 360, radius: radius).path
        translation = BoxDividers::Vector.translation_between(BoxDividers::Point.new(-radius, 0), point)
        path.translate(translation)
      }
    }
  end
end
