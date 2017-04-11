require 'matrix'
require_relative 'point'
require_relative 'transformations/affine'
require_relative 'transformations/proclike'
require_relative 'transformations/composer'

module BoxDividers
  module Transformations
    extend self

    MM_TO_PT = 2.8346456692913

    def mm_to_pt
      Affine.new(Matrix[
        [MM_TO_PT, 0, 0],
        [0, MM_TO_PT, 0],
        [0, 0, 1]
      ])
    end

    def x_axis_reflect
      Affine.new(Matrix[
        [1,0,0],
        [0,-1,0],
        [0,0,1]
      ])
    end

    def y_axis_reflect
      Affine.new(Matrix[
        [-1,0,0],
        [0,1,0],
        [0,0,1]
      ])
    end

    def xy_axis_reflect
      Composer.compose(x_axis_reflect, y_axis_reflect)
    end

    def round_to_n_decimal_places(n)
      Proclike.new(->(p) { [p.x.round(n), p.y.round(n)] })
    end
  end
end
