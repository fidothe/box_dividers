require_relative 'path_builder'
require_relative 'path_cleaner'
require_relative 'point'

module BoxDividers
  module DividerPath
    FULL_WIDTH_IN_UNITS = 10
    UNIT_WIDTH = 38
    UNIT_HEIGHT = 42
    CHANNEL_WIDTH = 4
    SLOT_WIDTH = 3.6

    def self.included(base)
      base.send(:attr_reader, :units_wide, :units_high)
    end

    def initialize(units_wide, units_high)
      @units_wide, @units_high = units_wide, units_high
    end

    def path
      PathCleaner.simplify(
        PathBuilder.connect(
          left_end,
          *bottom_units,
          right_end,
          *top_units
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

    def channel_width
      CHANNEL_WIDTH
    end

    def slot_tolerance
      (CHANNEL_WIDTH - SLOT_WIDTH) / 2.0
    end

    def slot_height
      mm_height / 2.0
    end

    def slot
      PathBuilder.connect(
        Point.new(0, 0),
        Point.new(slot_tolerance, 0),
        slot_interior,
        Point.new(slot_tolerance, 0)
      )
    end

    def slot_interior
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(0, slot_height)
        p << Point.new(slot_width, slot_height)
        p << Point.new(slot_width, 0)
      }
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

    def slot_width_path
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(channel_width, 0)
      }
    end

    def left_end
      full_or_interior(:left_end)
    end

    def right_end
      full_or_interior(:right_end)
    end

    def end_width
      full_or_interior(:end_width)
    end

    def interior_end_width
      slot_width + slot_tolerance
    end

    def full_end_width
      2
    end

    def full_or_interior(method_suffix)
      method_name = :"#{full_width? ? 'full' : 'interior'}_#{method_suffix}"
      send(method_name)
    end

    def full_width?
      units_wide >= FULL_WIDTH_IN_UNITS
    end

    def full_left_end
      PathBuilder.build { |p|
        p << Point.new(end_width, mm_height)
        p << Point.new(0, mm_height)
        p << Point.new(0, 0)
        p << Point.new(end_width, 0)
      }
    end

    def full_right_end
      PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(end_width, 0)
        p << Point.new(end_width, mm_height)
        p << Point.new(0, mm_height)
      }
    end
  end
end
