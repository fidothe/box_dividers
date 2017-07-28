require 'box_dividers/make'

module BoxDividers
  RSpec.describe Make do
    subject {
      Make.new({
        divider_sizes: [[10,4], [5,4]],
        width: 500,
        height: 600,
        sheet_edge_gap: 10,
        divider_gap: 5
      })
    }

    it "makes the correct dividers" do
      expected = [
        BottomDividerPath.new(10, 4), TopDividerPath.new(10, 4),
        BottomDividerPath.new(5,4), TopDividerPath.new(5, 4)
      ].map(&:path)

      expect(subject.divider_paths).to eq(expected)
    end

    it "makes the right containers" do
      expected = Draught::Container.new(BottomDividerPath.new(10, 4).path, min_gap: 5)

      expect(subject.containers.first).to eq(expected)
    end

    it "makes the right sheet builder" do
      containers = [double(Draught::Container)]
      allow(subject).to receive(:containers) { containers }
      expected = Draught::SheetBuilder.new({
        boxes: containers, max_height: 600, max_width: 500, outer_gap: 10
      })

      expect(subject.sheet_builder).to eq(expected)
    end

    it "can produce a sheet that hasn't been transformed for units correctly" do
      expect(subject.raw_sheet).to be_a(Draught::Sheet)
    end

    it "can produce a sheet that has been correctly transformed into PDF points" do
      expect(subject.sheet.width).to eq(subject.raw_sheet.width * Draught::Transformations::MM_TO_PT)
    end
  end
end
