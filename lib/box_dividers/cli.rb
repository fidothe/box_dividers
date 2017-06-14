require 'optparse'
require_relative './make'
require_relative './renderer'

module BoxDividers
  class CLI
    def self.run!
      new(ARGV).run
    end

    attr_reader :argv, :output_path

    def initialize(argv)
      @argv = argv
      @raw_opts = {}
    end

    def run
      Renderer.render_to_file(sheet, output_path)
    end

    def sheet
      @sheet ||= Make.sheet(opts.to_h)
    end

    def opts
      @opts || parse_options! && @opts
    end

    def output_path
      @output_path || parse_options! && @output_path
    end

    private

    def parse_options!
      raw_opts = {}
      args = argv.dup
      option_parser(raw_opts).parse!(args)

      raw_opts[:filename] = args.first unless args.empty?
      opts = Options.new(raw_opts)
      raise InvalidCLIOptions if opts.invalid?

      @output_path = File.expand_path(opts.filename, Dir.pwd)
      @opts = opts.to_h
      true
    end

    def option_parser(raw_opts)
      OptionParser.new { |parser|
        parser.on("-w", "--width WIDTH", OptionParser::DecimalNumeric, "Maximum sheet width") do |w|
          raw_opts[:width] = w
        end

        parser.on("-h", "--height HEIGHT", OptionParser::DecimalNumeric, "Maximum sheet height") do |h|
          raw_opts[:height] = h
        end

        parser.on("-s", "--divider-sizes SIZES", "Which divider sizes to generate") do |sizes|
          raw_opts[:divider_sizes] = sizes.split(' ').map { |size| size.strip.split(',').map { |num| Integer(num, 10) } }
        end

        parser.on("-e", "--sheet-edge-gap GAP", OptionParser::DecimalNumeric, "The gap, in mm, to leave between the edges of the sheet and dividers") do |gap|
          raw_opts[:sheet_edge_gap] = gap
        end

        parser.on("-g", "--divider-gap GAP", OptionParser::DecimalNumeric, "The gap, in mm, to leave between dividers on the sheet") do |gap|
          raw_opts[:divider_gap] = gap
        end

        parser.on("--help", "Prints this help") do
          puts parser
          raise CLIHelpShown
        end
      }
    end

    class Options
      ATTRS = [:width, :height, :divider_sizes, :sheet_edge_gap, :divider_gap, :filename]
      DEFAULTS = {
        divider_sizes: [[10,2], [5,2], [4,2], [3,2], [2,2]],
        sheet_edge_gap: 5,
        divider_gap: 5,
        filename: 'box-dividers.pdf'
      }

      attr_reader *ATTRS

      def initialize(attrs = {})
        DEFAULTS.merge(attrs).each do |attr, value|
          instance_variable_set(:"@#{attr}", value) if ATTRS.include?(attr)
        end
      end

      def invalid?
        !valid?
      end

      def valid?
        width && height
      end

      def to_h
        Hash[ATTRS.map { |method_name| [method_name, send(method_name)] }]
      end
    end

    class InvalidCLIOptions < StandardError
    end

    class CLIHelpShown < StandardError
    end
  end
end
