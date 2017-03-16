require 'prawn'

module BoxDividers
  class Pdf
    include Prawn::View

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def draw_divider
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
  end
end
