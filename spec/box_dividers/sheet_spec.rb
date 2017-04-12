require 'box_dividers/sheet'
require 'box_dividers/boxlike_examples'
require 'box_dividers/spec_box'
require 'box_dividers/point'
require 'box_dividers/vector'

module BoxDividers
  RSpec.describe Sheet do
    let(:box) { SpecBox.new(lower_left: Point.new(50,50), width: 200, height: 100) }
    let(:containers) { [box] }
    subject { Sheet.new(containers: containers, width: 1000, height: 600) }

    it_should_behave_like "a basic rectangular box-like thing"

    it "has its origin at 0,0 by default" do
      expect(subject.lower_left).to eq(Point::ZERO)
    end

    context "translation" do
      let(:point) { Point.new(100,100) }
      let(:translation) { Vector.translation_between(Point::ZERO, point) }

      it "correctly translates its boxes" do
        translated = subject.translate(translation)
        expect(translated.containers).to eq([box.translate(translation)])
      end
    end
  end
end
