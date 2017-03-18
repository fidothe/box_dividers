require_relative 'path_builder'
require_relative 'path_cleaner'
require_relative 'point'

module BoxDividers
  class TopDividerPath
    UNIT_WIDTH = 38
    UNIT_HEIGHT = 42
    CHANNEL_WIDTH = 4
    SLOT_WIDTH = 3.6

    attr_reader :units_wide, :units_high

    def initialize(units_wide, units_high)
      @units_wide, @units_high = units_wide, units_high
    end

    def path
      units = [unit, slot] * units_wide
      units.pop
      PathCleaner.simplify(
        PathBuilder.connect(
          left_full_height_end,
          *units,
          right_full_height_end
        )
      )
    end

    def mm_height
      units_high * UNIT_HEIGHT
    end

    def mm_width
      (units_wide * UNIT_WIDTH) + ((units_wide - 1) * CHANNEL_WIDTH)
    end

    def slot_width
      SLOT_WIDTH
    end

    def slot_tolerance
      (CHANNEL_WIDTH - SLOT_WIDTH) / 2.0
    end

    def slot_height
      mm_height / 2.0
    end

    def slot
      slot_interior = PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(0, slot_height)
        p << Point.new(slot_width, slot_height)
        p << Point.new(slot_width, 0)
      }
      PathBuilder.connect(
        Point.new(0, 0),
        Point.new(slot_tolerance, 0),
        slot_interior,
        Point.new(slot_tolerance, 0)
      )
    end

    def unit
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << tab.translate(Point.new(15, 0))
        p << Point.new(UNIT_WIDTH, 0)
      }
    end

    def tab
      tab_bottom_y = -1.5
      tab_right_x = 8
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(0, tab_bottom_y)
        p << Point.new(tab_right_x, tab_bottom_y)
        p << Point.new(tab_right_x, 0)
      }
    end

    def left_full_height_end
      PathBuilder.build { |p|
        p << Point.new(0, mm_height)
        p << Point.new(0, 0)
        p << Point.new(2, 0)
      }
    end

    def right_full_height_end
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(2, 0)
        p << Point.new(2, mm_height)
      }
    end
  end
end
