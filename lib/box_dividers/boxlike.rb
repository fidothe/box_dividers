require_relative 'point'
require_relative 'vector'

module BoxDividers
  module Boxlike
    def lower_left
      raise NotImplementedError, "includers of Boxlike must implement #lower_left"
    end

    def width
      raise NotImplementedError, "includers of Boxlike must implement #width"
    end

    def height
      raise NotImplementedError, "includers of Boxlike must implement #height"
    end

    def box_type
      raise NotImplementedError, "includers of Boxlike must implement #box_type"
    end

    def lower_right
      @lower_right ||= lower_left.translate(BoxDividers::Vector.new(width, 0))
    end

    def upper_right
      @upper_right ||= lower_left.translate(BoxDividers::Vector.new(width, height))
    end

    def upper_left
      @upper_left ||= lower_left.translate(BoxDividers::Vector.new(0, height))
    end

    def centre_left
      @centre_left ||= lower_left.translate(BoxDividers::Vector.new(0, height/2.0))
    end

    def lower_centre
      @lower_centre ||= lower_left.translate(BoxDividers::Vector.new(width/2.0, 0))
    end

    def centre_right
      @centre_right ||= lower_right.translate(BoxDividers::Vector.new(0, height / 2.0))
    end

    def upper_centre
      @upper_centre ||= upper_left.translate(BoxDividers::Vector.new(width/2.0, 0))
    end

    def centre
      @centre ||= lower_left.translate(BoxDividers::Vector.new(width/2.0, height/2.0))
    end

    def corners
      [lower_left, lower_right, upper_right, upper_left]
    end

    def move_to(point)
      translation = BoxDividers::Vector.translation_between(lower_left, point)
      return self if translation == BoxDividers::Vector::NULL
      translate(translation)
    end

    def translate(point)
      raise NotImplementedError
    end

    def transform(transformer)
      raise NotImplementedError
    end

    def paths
      raise NotImplementedError
    end

    def containers
      raise NotImplementedError
    end

    def overlaps?(other_box)
      !disjoint?(other_box)
    end

    def horizontal_extent
      @horizontal_extent ||= lower_left.x..upper_right.x
    end

    def vertical_extent
      @vertical_extent ||= lower_left.y..upper_right.y
    end

    def disjoint?(other_box)
      h = other_box.horizontal_extent
      v = other_box.vertical_extent

      horizontal_disjoint?(h.first, h.last) ||
        vertical_disjoint?(v.first, v.last)
    end

    def include_point?(point)
      horizontal_extent.include?(point.x) && vertical_extent.include?(point.y)
    end

    def min_gap
      0
    end

    private

    def horizontal_disjoint?(other_left, other_right)
      left = horizontal_extent.first
      right = horizontal_extent.last

      other_left == right || other_right == left ||
        other_left > right || other_right < left
    end

    def vertical_disjoint?(other_bottom, other_top)
      bottom = vertical_extent.first
      top = vertical_extent.last

      other_bottom == top || other_top == bottom ||
        other_top < bottom || other_bottom > top
    end
  end
end
