require_relative '../draught/path_builder'
require_relative '../draught/path_cleaner'
require_relative './divider_path'

module BoxDividers
  class TopDividerPath
    include DividerPath

    def top_units
      []
    end

    def bottom_units
      [bottom_path]
    end

    def bottom_path
      PathBuilder.build { |p|
        p << bottom_start_point
        (1...units_wide).each do |n|
          p << tab.translate(Vector.new(unit_offset(n), 0))
          p << slot.translate(Vector.new(unit_offset(n), 0))
        end
        p << tab.translate(Vector.new(unit_offset(units_wide), 0))
        p << bottom_end_point
      }
    end

    def bottom_start_point
      x = full_width? ? 0 : corner_radius
      Point.new(x, 0)
    end

    def bottom_end_point
      offset = full_width? ? 0 : corner_radius
      x = mm_width - offset
      Point.new(x, 0)
    end

    def slot
      @slot ||= begin
        untranslated_slot.move_to(abs_slot_centre_position, position: :lower_centre)
      end
    end

    def bottom_unit
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << tab.move_to(line.centre, position: :upper_centre)
        p << Point.new(UNIT_WIDTH, 0)
      }
    end

    def interior_left_end
      top = Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Line.horizontal(-end_width),
          Line.vertical(-slot_height),
          Line.horizontal(end_width)
        ]
      })
      bottom = Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Line.vertical(-slot_height),
          Line.horizontal(corner_radius)
        ]
      })
      PathBuilder.connect(top, bottom)
    end

    def interior_right_end
      bottom = Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Line.horizontal(corner_radius),
          Line.vertical(slot_height)
        ]
      })
      top = Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Line.horizontal(end_width),
          Line.vertical(slot_height),
          Line.horizontal(-end_width)
        ]
      })
      PathBuilder.connect(bottom, top)
    end
  end
end
