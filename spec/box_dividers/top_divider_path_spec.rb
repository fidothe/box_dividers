require 'box_dividers/top_divider_path'

module BoxDividers
  RSpec.describe TopDividerPath do
    let(:units_high) { 2 }
    subject { TopDividerPath.new(units_wide, units_high) }

    context "full-width" do
      let(:units_wide) { 10 }

      it "should run without errors given sensible inputs" do
        expect { subject.path }.not_to raise_error
      end

      it "produces a Path" do
        expect(subject.path.translate(Vector::NULL).lower_left).to eq(subject.path.lower_left)
      end
    end

    context "partial-width" do
      let(:units_wide) { 5 }

      it "should run without errors given sensible inputs" do
        expect { subject.path }.not_to raise_error
      end

      it "produces a Path" do
        expect(subject.path.translate(Vector::NULL).lower_left).to eq(subject.path.lower_left)
      end
    end
  end
end
