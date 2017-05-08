require_relative './path_builder'
require_relative './path_cleaner'
require_relative './point'
require_relative './vector'
require_relative './arc_builder'

module BoxDividers
  module DividerPath
    FULL_WIDTH_IN_UNITS = 10
    UNIT_WIDTH = 38
    UNIT_HEIGHT = 42
    CHANNEL_WIDTH = 4
    SLOT_WIDTH = 3.6
    CORNER_RADIUS = 1

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

    def corner_radius
      CORNER_RADIUS
    end

    def slot
      side = PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(slot_tolerance, 0)
      }
      PathBuilder.connect(
        side,
        slot_interior,
        side
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
        p << tab.translate(Vector.new(15, 0))
        p << Point.new(UNIT_WIDTH, 0)
      }
    end

    def tab
      tab_bottom_y = -1.5
      tab_width = 8
      tab_right_x = 8
      left = PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(0, tab_bottom_y + corner_radius)
      }
      centre = PathBuilder.build { |p|
        p << Point.new(0, 0)
        p << Point.new(tab_width - (2 * corner_radius), 0)
      }
      right = PathBuilder.build { |p|
        p << Point.new(0, tab_bottom_y + corner_radius)
        p << Point.new(0, 0)
      }
      PathBuilder.connect(
        left,
        ArcBuilder.degrees(angle: 90, starting_angle: 180, radius: 1).path,
        centre,
        ArcBuilder.degrees(angle: 90, starting_angle: 270, radius: 1).path,
        right
      )
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
