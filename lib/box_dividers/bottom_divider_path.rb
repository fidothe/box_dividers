require_relative 'path_builder'
require_relative 'path_cleaner'
require_relative 'point'
require_relative 'divider_path'
require_relative 'transformations'

module BoxDividers
  class BottomDividerPath
    include DividerPath

    def bottom_units
      [bottom_path]
    end

    def bottom_path
      PathBuilder.build { |p|
        p << Point::ZERO
        (1..units_wide).each do |n|
          p << tab.translate(Vector.new(unit_offset(n), 0))
        end
        p << Point.new(mm_width, 0)
      }
    end

    def top_units
      [top_path]
    end

    def top_path
      PathBuilder.build { |p|
        p << top_start_point
        (1...units_wide).each do |n|
          p << slot.translate(Vector.new(-unit_offset(n), 0))
        end
        p << top_end_point
      }
    end

    def top_start_point
      x = full_width? ? 0 : -corner_radius
      Point.new(x, mm_height)
    end

    def top_end_point
      offset = full_width? ? 0 : corner_radius
      x = (mm_width - offset) * -1
      Point.new(x, mm_height)
    end

    def slot
      @slot ||= begin
        slot_centre_position = abs_slot_centre_position.translate(Vector.new(0,mm_height)).transform(Transformations.y_axis_reflect)
        untranslated_slot.transform(Transformations.xy_axis_reflect).move_to(slot_centre_position, position: :upper_centre)
      end
    end

    def interior_left_end
      top = Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Line.horizontal(-corner_radius),
          Line.vertical(-slot_height)
        ]
      })
      bottom = Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Line.horizontal(-end_width),
          Line.vertical(-slot_height),
          Line.horizontal(end_width)
        ]
      })
      PathBuilder.connect(top, bottom)
    end

    def interior_right_end
      bottom = Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Line.horizontal(end_width),
          Line.vertical(slot_height),
          Line.horizontal(-end_width)
        ]
      })
      top = Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Line.vertical(slot_height),
          Line.horizontal(-corner_radius)
        ]
      })
      PathBuilder.connect(bottom, top)
    end
  end
end
