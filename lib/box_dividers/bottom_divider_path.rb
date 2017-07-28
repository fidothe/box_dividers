require_relative '../draught/path_builder'
require_relative '../draught/path_cleaner'
require_relative '../draught/point'
require_relative '../draught/transformations'
require_relative './divider_path'

module BoxDividers
  class BottomDividerPath
    include DividerPath

    def bottom_units
      [bottom_path]
    end

    def bottom_path
      Draught::PathBuilder.build { |p|
        p << Draught::Point::ZERO
        (1..units_wide).each do |n|
          p << tab.translate(Draught::Vector.new(unit_offset(n), 0))
        end
        p << Draught::Point.new(mm_width, 0)
      }
    end

    def top_units
      [top_path]
    end

    def top_path
      Draught::PathBuilder.build { |p|
        p << top_start_point
        (1...units_wide).each do |n|
          p << slot.translate(Draught::Vector.new(-unit_offset(n), 0))
        end
        p << top_end_point
      }
    end

    def top_start_point
      x = full_width? ? 0 : -corner_radius
      Draught::Point.new(x, mm_height)
    end

    def top_end_point
      offset = full_width? ? 0 : corner_radius
      x = (mm_width - offset) * -1
      Draught::Point.new(x, mm_height)
    end

    def slot
      @slot ||= begin
        slot_centre_position = abs_slot_centre_position.translate(Draught::Vector.new(0,mm_height)).transform(Draught::Transformations.y_axis_reflect)
        untranslated_slot.transform(Draught::Transformations.xy_axis_reflect).move_to(slot_centre_position, position: :upper_centre)
      end
    end

    def interior_left_end
      top = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.horizontal(-corner_radius),
          Draught::Line.vertical(-slot_height)
        ]
      })
      bottom = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.horizontal(-end_width),
          Draught::Line.vertical(-slot_height),
          Draught::Line.horizontal(end_width)
        ]
      })
      Draught::PathBuilder.connect(top, bottom)
    end

    def interior_right_end
      bottom = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.horizontal(end_width),
          Draught::Line.vertical(slot_height),
          Draught::Line.horizontal(-end_width)
        ]
      })
      top = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.vertical(slot_height),
          Draught::Line.horizontal(-corner_radius)
        ]
      })
      Draught::PathBuilder.connect(bottom, top)
    end
  end
end
