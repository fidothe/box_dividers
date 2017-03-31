require 'box_dividers/container'
require 'box_dividers/boxlike_examples'
require 'box_dividers/spec_box'
require 'box_dividers/point'

module BoxDividers
  RSpec.describe Container do
    let(:box) { SpecBox.new(lower_left: Point::ZERO, width: 200, height: 100) }
    subject { Container.new(box, min_gap: 50) }

    it_should_behave_like "a basic rectangular box-like thing"

    it "reports the minimum gap it should have between it and any other Container" do
      expect(subject.min_gap).to eq(50)
    end

    context "min_gap and transformation" do
      specify "we assume transformations are simply uniform and the min_gap gets scaled as if it were an x co-ord" do
        transformed = subject.transform(->(x,y) { [2 * x, 2 * y] })
        expect(transformed.min_gap).to eq(100)
      end
    end

    context "paths and containers" do
      it "delegates #paths to its box" do
        allow(box).to receive(:paths) { [:path] }
        expect(subject.paths).to eq([:path])
      end

      it "delegates #containers to its box" do
        allow(box).to receive(:containers) { [:container] }
        expect(subject.containers).to eq([:container])
      end
    end
  end
end
