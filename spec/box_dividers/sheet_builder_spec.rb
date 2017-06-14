require 'box_dividers/sheet_builder'
require 'box_dividers/spec_box'
require 'prawn'

module BoxDividers
  RSpec.describe SheetBuilder do
    let(:wide_box) { SpecBox.zeroed(width: 300, height: 100, min_gap: 50) }
    let(:args) { {boxes: [wide_box], max_width: 1000, max_height: 600, outer_gap: 5} }
    subject { SheetBuilder.new(args) }

    context "comparison" do
      it "compares equal to another sheet builder with the same boxes and other args" do
        other = SheetBuilder.new(args)

        expect(subject).to eq(other)
      end

      it "doesn't compare equal if a detail is changed" do
        other = SheetBuilder.new(args.merge(outer_gap: 10))

        expect(subject).not_to eq(other)
      end
    end

    context "nesting a single box fills the sheet with as many instances as possible" do
      let(:sheet) { subject.sheet }

      specify "fills it with the correct number of boxes" do
        expect(sheet.paths.size).to eq(8)
      end

      specify "the sheet is the minimum needed width" do
        expect(sheet.width).to eq(660)
      end

      specify "the sheet is the minimum needed height" do
        expect(sheet.height).to eq(560)
      end
    end
  end
end
