require 'box_dividers/transformations/affine'
require 'box_dividers/transformations/proclike'
require 'box_dividers/transformations/shared_examples'
require 'box_dividers/point'

module BoxDividers::Transformations
  RSpec.describe Affine do
    let(:transformation_matrix) {
      Matrix[[-1, 0, 0],[0, -1, 0],[0,0,1]]
    }
    let(:input_point) { BoxDividers::Point.new(1,2) }
    let(:expected_point) { BoxDividers::Point.new(-1,-2) }

    subject { Affine.new(transformation_matrix) }

    include_examples "transformation object fundamentals"
    include_examples "single-transform transformation object"
    include_examples "producing a transform-compatible version of itself"

    it "claims to be affine" do
      expect(Affine.new(transformation_matrix).affine?).to be true
    end

    context "coalescing two Affine transforms together into a new transform" do
      let(:t1) { Affine.new(Matrix[[-1, 0, 0],[0, 1, 0],[0, 0, 1]]) }
      let(:t2) { Affine.new(Matrix[[1, 0, 0],[0, -1, 0],[0, 0, 1]]) }

      specify "produces a new Affine transform by matrix multiplication" do
        expect(t2.coalesce(t1).call(input_point)).to eq(BoxDividers::Point.new(-1,-2))
      end

      specify "the matrix of the new transform is the product of the inputs" do
        expected_matrix = Matrix[[-1, 0, 0],[0, -1, 0],[0, 0, 1]]

        coalesced = t2.coalesce(t1)

        expect(coalesced.transformation_matrix).to eq(expected_matrix)
      end

      specify "attempting to coalesce an Affine transform with another kind raises TypeError" do
        other = Proclike.new(->(p) { p })

        expect { subject.coalesce(other) }.to raise_error(TypeError)
      end
    end
  end
end
