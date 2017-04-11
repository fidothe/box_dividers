require 'box_dividers/transformations/composition'
require 'box_dividers/transformations/affine'
require 'box_dividers/point'
require 'box_dividers/transformations/shared_examples'

module BoxDividers::Transformations
  RSpec.describe Composer do
    let(:t1) { Affine.new(Matrix[[-1, 0, 0],[0, 1, 0],[0, 0, 1]]) }
    let(:t2) { Affine.new(Matrix[[1, 0, 0],[0, -1, 0],[0, 0, 1]]) }

    it "compares equality based on its transforms" do
      expect(Composition.new([t2, t1])).to eq(Composition.new([t2, t1]))
    end

    context "behaving like a transform" do
      let(:input_point) { BoxDividers::Point.new(1,2) }
      let(:expected_point) { BoxDividers::Point.new(-1,-2) }
      subject { Composition.new([t1, t2]) }

      include_examples "transformation object fundamentals"
      include_examples "producing a transform-compatible version of itself"
    end
  end
end
