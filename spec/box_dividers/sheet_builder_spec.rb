require 'box_dividers/sheet_builder'
require 'box_dividers/spec_box'
require 'prawn'

module BoxDividers
  class SpecPDF
    include Prawn::View

    def initialize(sheet)
      @sheet = sheet
    end

    def document
      @document ||= Prawn::Document.new(page_size: [@sheet.width+50, @sheet.height+50], margin: 25)
    end

    def draw_box(box)
      stroke { rectangle [box.upper_left.x, box.upper_left.y], box.width, box.height }
    end

    def draw_sheet
      @sheet.boxes.each do |box|
        draw_box(box)
      end
    end
  end

  RSpec.describe SheetBuilder do
    let(:wide_box) { SpecBox.zeroed(width: 300, height: 100, min_gap: 50) }

    context "nesting a single box fills the sheet with as many instances as possible" do
      subject {
        wb = wide_box
        SheetBuilder.build(max_width: 1000, max_height: 600, outer_gap: 5) {
          add wb
        }
      }

      specify "fills it with the correct number of boxes" do
        pdf = SpecPDF.new(subject)
        pdf.draw_sheet
        pdf.save_as('sheet.pdf')
        expect(subject.boxes.size).to eq(8)
      end

      specify "the sheet is the minimum needed width" do
        expect(subject.width).to eq(660)
      end

      specify "the sheet is the minimum needed height" do
        expect(subject.height).to eq(560)
      end
    end
  end
end
