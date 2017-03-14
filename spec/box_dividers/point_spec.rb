require 'box_dividers/point'

module BoxDividers
  RSpec.describe Point do
    subject { Point.new(1, 2) }

    it "returns its x" do
      expect(subject.x).to eq(1)
    end

    it "returns its y" do
      expect(subject.y).to eq(2)
    end

    it "can return itself as an array of points" do
      expect(subject.points).to eq([subject])
    end
  end
end
