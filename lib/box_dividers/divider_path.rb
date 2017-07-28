require_relative '../draught/path_builder'
require_relative '../draught/path_cleaner'
require_relative '../draught/point'
require_relative '../draught/vector'
require_relative '../draught/arc_builder'
require_relative '../draught/line'
require_relative '../draught/corner'

module BoxDividers
  module DividerPath
    FULL_WIDTH_IN_UNITS = 10
    UNIT_SQUARE = 38
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
      Draught::PathCleaner.simplify(
        Draught::PathBuilder.connect(
          left_end,
          *bottom_units,
          right_end,
          *top_units
        )
      )
    end

    def mm_height
      units_high * unit_height
    end

    def unit_height
      UNIT_SQUARE
    end

    def mm_width
      (units_wide * unit_width) + ((units_wide - 1) * channel_width)
    end

    def unit_width
      UNIT_SQUARE
    end

    def channel_width
      CHANNEL_WIDTH
    end

    def unit_offset(unit_n)
      (unit_n - 1) * base_unit_offset
    end

    def base_unit_offset
      unit_width + channel_width
    end

    def slot_tolerance
      (channel_width - slot_width) / 2.0
    end

    def slot_width
      SLOT_WIDTH
    end

    def slot_height
      mm_height / 2.0
    end

    def corner_radius
      CORNER_RADIUS
    end

    def untranslated_slot
      lip_width = [slot_tolerance, corner_radius].max
      lip = Draught::Line.horizontal(lip_width)
      slot = Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [lip, slot_interior, lip]
      })
    end

    def slot_interior
      Draught::PathBuilder.connect(
        Draught::Line.vertical(slot_height),
        Draught::Line.horizontal(slot_width),
        Draught::Line.vertical(-slot_height)
      )
    end

    def abs_slot_centre_position
      Draught::Line.horizontal((unit_width + (channel_width / 2.0))).lower_right
    end

    def tab
      @tab ||= begin
        tab_height = 1.5
        tab_width = 8
        unit_line = Draught::Line.horizontal(unit_width)
        left = Draught::Line.vertical(-tab_height)
        centre = Draught::Line.horizontal(tab_width)
        right = Draught::Line.vertical(tab_height)
        tab = Draught::Corner.join_rounded(radius: corner_radius, paths: [left, centre, right])
        tab.move_to(unit_line.centre, position: :upper_centre)
      end
    end

    def slot_width_path
      Draught::Line.horizontal(channel_width)
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
      Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.horizontal(-end_width),
          Draught::Line.vertical(-mm_height),
          Draught::Line.horizontal(end_width)
        ]
      })
    end

    def full_right_end
      Draught::Corner.join_rounded({
        radius: corner_radius,
        paths: [
          Draught::Line.horizontal(end_width),
          Draught::Line.vertical(mm_height),
          Draught::Line.horizontal(-end_width)
        ]
      })
    end
  end
end
