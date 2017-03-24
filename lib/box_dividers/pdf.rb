require_relative 'transformations'
require 'prawn'

module BoxDividers
  class Pdf
    include Prawn::View

    attr_reader :bounding_box

    def initialize(bounding_box)
      @bounding_box = bounding_box
    end

    def draw_path(path)
      points = path.points.dup
      first_point = points.shift
      close_and_stroke do
        move_to first_point.x, first_point.y
        points.each do |point|
          line_to point.x, point.y
        end
        line_to first_point.x, first_point.y
      end
    end

    def draw_divider
      bounding_box.transform(Transformations.mm_to_pt).paths.each do |path|
        draw_path(path)
      end
    end
  end
end
