require_relative './bottom_divider_path'
require_relative './top_divider_path'
require_relative './container'
require_relative './sheet_builder'
require_relative './transformations'

module BoxDividers
  class Make
    attr_reader :divider_sizes, :max_width, :max_height, :sheet_edge_gap, :divider_gap

    def self.sheet(args)
      new(args).sheet
    end

    def initialize(args)
      @divider_sizes = args.fetch(:divider_sizes)
      @max_width = args.fetch(:width)
      @max_height = args.fetch(:height)
      @divider_gap = args.fetch(:divider_gap)
      @sheet_edge_gap = args.fetch(:sheet_edge_gap)
    end

    def sheet
      @sheet ||= raw_sheet.transform(Transformations.mm_to_pt)
    end

    def raw_sheet
      @raw_sheet ||= sheet_builder.sheet
    end

    def sheet_builder
      @sheet_builder ||= SheetBuilder.new({
        boxes: containers,
        max_width: max_width,
        max_height: max_height,
        outer_gap: sheet_edge_gap
      })
    end

    def containers
      @containers ||= divider_paths.map { |path| Container.new(path, min_gap: divider_gap) }
    end

    def divider_paths
      @divider_paths ||= divider_sizes.flat_map { |units_wide, units_high|
        [
          BottomDividerPath.new(units_wide, units_high).path,
          TopDividerPath.new(units_wide, units_high).path
        ]
      }
    end
  end
end
