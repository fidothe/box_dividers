require_relative './common'

module Draught
  module Transformations
    class Composition
      include Transformations::Common

      attr_reader :transforms

      def initialize(transforms)
        @transforms = transforms
      end

      def call(point)
        transforms.inject(point) { |point, transform| transform.call(point) }
      end

      def affine?
        false
      end

      def to_transform
        self
      end

      def ==(other)
        other.transforms == transforms
      end
    end
  end
end
