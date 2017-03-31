require_relative 'path_builder'
require_relative 'path_cleaner'
require_relative 'point'
require_relative 'divider_path'
require_relative 'transformations'

module BoxDividers
  class BottomDividerPath
    include DividerPath

    def top_units
      units = [top_unit, slot] * units_wide
      units[0..-2]
    end

    def bottom_units
      units = [bottom_unit, slot_width_path] * units_wide
      units[0..-2]
    end

    def top_unit
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(-UNIT_WIDTH, 0)
      }
    end

    def bottom_unit
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << tab.translate(Point.new(15, 0))
        p << Point.new(UNIT_WIDTH, 0)
      }
    end

    def slot
      super.transform(Transformations.xy_axis_reflect)
    end

    def interior_left_end
      PathBuilder.build { |p|
        p << Point.new(end_width, mm_height)
        p << Point.new(end_width, mm_height)
        p << Point.new(end_width, slot_height)
        p << Point.new(0, slot_height)
        p << Point.new(0, 0)
        p << Point.new(end_width, 0)
      }
    end

    def interior_right_end
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(end_width, 0)
        p << Point.new(end_width, slot_height)
        p << Point.new(0, slot_height)
        p << Point.new(0, mm_height)
      }
    end
  end
end
