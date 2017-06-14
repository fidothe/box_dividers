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
      begin
        Renderer.render_to_file(sheet, output_path)
      rescue CLIHelpShown
        exit 0
      rescue InvalidCLIOptions
        puts "Sorry, you passed options I don't understand. Here's a quick summary of what I understand:"
        puts
        puts option_parser
        exit 1
      end
    end

    def sheet
      @sheet ||= Make.sheet(opts.to_h)
    end

    def opts
      @opts ||= option_parser.opts
    end

    def output_path
      @output_path ||= File.expand_path(opts.filename, Dir.pwd)
    end

    private

    def option_parser
      @option_parser ||= OptionParser.parse!(argv)
    end

    class OptionParser
      def self.parse!(args)
        new.parse!(args)
      end

      attr_reader :raw_opts, :args

      def initialize
        @raw_opts = {}
      end

      def parser
        @parser ||= ::OptionParser.new { |parser|
          parser.banner = "Usage: #{parser.program_name} -w WIDTH -h HEIGHT [options] FILE"
          parser.on("-w", "--width WIDTH", ::OptionParser::DecimalNumeric, "Maximum sheet width") do |w|
            raw_opts[:width] = w
          end

          parser.on("-h", "--height HEIGHT", ::OptionParser::DecimalNumeric, "Maximum sheet height") do |h|
            raw_opts[:height] = h
          end

          parser.on("-s", "--divider-sizes SIZES", "Which divider sizes to generate", "Space-separated UNITS_WIDE,UNITS_HIGH list", 'e.g. -s "10,4 10,2"') do |sizes|
            raw_opts[:divider_sizes] = sizes.split(' ').map { |size| size.strip.split(',').map { |num| Integer(num, 10) } }
          end

          parser.on("-e", "--sheet-edge-gap GAP", ::OptionParser::DecimalNumeric, "The gap, in mm, to leave between the edges", "of the sheet and dividers") do |gap|
            raw_opts[:sheet_edge_gap] = gap
          end

          parser.on("-g", "--divider-gap GAP", ::OptionParser::DecimalNumeric, "The gap, in mm, to leave between dividers", "on the sheet") do |gap|
            raw_opts[:divider_gap] = gap
          end

          parser.on("--help", "Prints this help") do
            puts parser
            raise CLIHelpShown
          end

          parser.on("--version", "Print the version") do
            puts "#{parser.program_name} #{BoxDividers::VERSION}"
            raise CLIHelpShown
          end
        }
      end

      def parse!(args)
        @args = args.dup
        parser.parse!(@args)
        self
      end

      def opts
        @opts ||= Options.validated(raw_opts.merge(filename_arg))
      end

      def to_s
        parser.to_s
      end

      private

      def filename_arg
        args.empty? ? {} : {filename: args.first}
      end
    end

    class Options
      ATTRS = [:width, :height, :divider_sizes, :sheet_edge_gap, :divider_gap, :filename]
      DEFAULTS = {
        divider_sizes: [[10,2], [5,2], [4,2], [3,2], [2,2]],
        sheet_edge_gap: 5,
        divider_gap: 5,
        filename: 'box-dividers.pdf'
      }

      def self.validated(attrs)
        opts = new(attrs)
        raise InvalidCLIOptions if opts.invalid?
        opts
      end

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
