require 'box_dividers/corner'
require 'box_dividers/arc_builder'
require 'box_dividers/line'
require 'box_dividers/path_builder'

module BoxDividers
  RSpec.describe Corner do
    describe "rounded corners" do
      context "joining two paths at right-angles returns a new path containing the incoming path up to the point the arc starts, the arc, and the rest of the outgoing path" do
        let(:horizontal) { Line.horizontal(10).path }
        let(:up) { Line.vertical(10).path }
        let(:down) { Line.vertical(-10).path }

        specify "when the incoming line is left-right and the outgoing line is bottom-to-top" do
          expected = PathBuilder.build { |p|
            p << Point::ZERO << Point.new(9,0)
            p << ArcBuilder.degrees(angle: 90, radius: 1, starting_angle: 270).curve.translate(Vector.new(9,0))
            p << Point.new(10,10)
          }

          joined = Corner::Rounded.join(radius: 1, paths: [horizontal, up])

          expect(joined).to approximate(expected).within(0.00001)
        end
      end
    end
  end
end
