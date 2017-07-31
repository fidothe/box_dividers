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
      Draught::PathBuilder.build { |p|
        p << bottom_start_point
        (1...units_wide).each do |n|
          p << tab.translate(Draught::Vector.new(unit_offset(n), 0))
          p << slot.translate(Draught::Vector.new(unit_offset(n), 0))
        end
        p << tab.translate(Draught::Vector.new(unit_offset(units_wide), 0))
        p << bottom_end_point
      }
    end

    def bottom_start_point
      x = full_width? ? 0 : corner_radius
      Draught::Point.new(x, 0)
    end

    def bottom_end_point
      offset = full_width? ? 0 : corner_radius
      x = mm_width - offset
      Draught::Point.new(x, 0)
    end

    def slot
      @slot ||= begin
        untranslated_slot.move_to(abs_slot_centre_position, position: :lower_centre)
      end
    end

    def bottom_unit
      Draught::PathBuilder.build { |p|
        p << Draught::Point.new(0, 0)
        p << tab.move_to(line.centre, position: :upper_centre)
        p << Draught::Point.new(UNIT_WIDTH, 0)
      }
    end

    def interior_left_end
      top = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.horizontal(-end_width),
          Draught::Line.vertical(-slot_height),
          Draught::Line.horizontal(end_width)
        ]
      })
      bottom = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.vertical(-slot_height),
          Draught::Line.horizontal(corner_radius)
        ]
      })
      Draught::PathBuilder.connect(top, bottom)
    end

    def interior_right_end
      bottom = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.horizontal(corner_radius),
          Draught::Line.vertical(slot_height)
        ]
      })
      top = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.horizontal(end_width),
          Draught::Line.vertical(slot_height),
          Draught::Line.horizontal(-end_width)
        ]
      })
      Draught::PathBuilder.connect(bottom, top)
    end
  end
end
