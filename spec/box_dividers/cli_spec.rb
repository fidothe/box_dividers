require 'box_dividers/cli'
require 'shellwords'
require 'tmpdir'

module BoxDividers
  RSpec.describe CLI do
    describe "parsing command-line options" do
      context "the minimal set of options" do
        specify "is the sheet size" do
          args = Shellwords.split('--width 200 --height 100')
          cli = CLI.new(args)

          expect(cli.opts.width).to eq(200)
          expect(cli.opts.height).to eq(100)
        end

        specify "can be specified via -w and -h" do
          args = Shellwords.split('-w 200 -h 100')
          cli = CLI.new(args)

          expect(cli.opts.width).to eq(200)
          expect(cli.opts.height).to eq(100)
        end

        specify "if not provided then raise an error" do
          expect { CLI.new([]).opts }.to raise_error(CLI::InvalidCLIOptions)
        end
      end

      context "setting which divider sizes to generate" do
        specify "defaults to 10x2, 5x2, 4x2, 3x2, 2x2" do
          args = Shellwords.split('-w 200 -h 100')
          cli = CLI.new(args)

          expect(cli.opts.divider_sizes).to eq([[10,2], [5,2], [4,2], [3,2], [2,2]])
        end

        specify "uses a 'w,h w,h' comma- and space-separated format" do
          args = Shellwords.split('-w 200 -h 100 --divider-sizes "10,4 5,4"')
          cli = CLI.new(args)

          expect(cli.opts.divider_sizes).to eq([[10,4], [5,4]])
        end

        specify "can be specified via -s" do
          args = Shellwords.split('-w 200 -h 100 -s "10,4 5,4"')
          cli = CLI.new(args)

          expect(cli.opts.divider_sizes).to eq([[10,4], [5,4]])
        end
      end

      context "setting the gap between the edge of the sheet and the work pieces" do
        specify "defaults to 5mm" do
          args = Shellwords.split('-w 200 -h 100')
          cli = CLI.new(args)

          expect(cli.opts.sheet_edge_gap).to eq(5)
        end

        specify "can be specified by --sheet-edge-gap" do
          args = Shellwords.split('-w 200 -h 100 --sheet-edge-gap 10')
          cli = CLI.new(args)

          expect(cli.opts.sheet_edge_gap).to eq(10)
        end

        specify "can be specified by -e" do
          args = Shellwords.split('-w 200 -h 100 -e 10')
          cli = CLI.new(args)

          expect(cli.opts.sheet_edge_gap).to eq(10)
        end
      end

      context "setting the gap between work pieces" do
        specify "defaults to 5mm" do
          args = Shellwords.split('-w 200 -h 100')
          cli = CLI.new(args)

          expect(cli.opts.divider_gap).to eq(5)
        end

        specify "can be specified by --divider-gap" do
          args = Shellwords.split('-w 200 -h 100 --divider-gap 10')
          cli = CLI.new(args)

          expect(cli.opts.divider_gap).to eq(10)
        end

        specify "can be specified by -g" do
          args = Shellwords.split('-w 200 -h 100 -g 10')
          cli = CLI.new(args)

          expect(cli.opts.divider_gap).to eq(10)
        end
      end

      context "setting the output file name" do
        specify "defaults to box-dividers.pdf" do
          args = Shellwords.split('-w 200 -h 100')
          cli = CLI.new(args)

          expect(cli.opts.filename).to eq('box-dividers.pdf')
        end

        specify "is set from the argument" do
          args = Shellwords.split('-w 200 -h 100 my-great-dividers.pdf')
          cli = CLI.new(args)

          expect(cli.opts.filename).to eq('my-great-dividers.pdf')
        end
      end
    end
  end

  describe "creating the sheet and renderer" do
    let(:filename) { "my-great-dividers.pdf" }
    let(:args) { Shellwords.split("-w 200 -h 100 -s 2,2 #{filename}") }
    subject { CLI.new(args) }

    context "the sheet" do
      specify "gets created correctly" do
        sheet = double(Sheet)

        expect(Make).to receive(:sheet).with(subject.opts.to_h) { sheet }

        expect(subject.sheet).to be(sheet)
      end
    end

    context "the output path" do
      specify "uses the working dir of the process to expand the passed filename" do
        Dir.mktmpdir do |dir|
          expected = File.realdirpath(filename, dir)
          Dir.chdir(dir) do
            cli = CLI.new(args)

            expect(cli.output_path.to_s).to eq(expected)
          end
        end
      end

      specify "handles absolute paths handed in as filenames as absolute paths" do
        args = Shellwords.split('-w 200 -h 100 -s 2,2 /path/to/output.pdf')
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            cli = CLI.new(args)

            expect(cli.output_path.to_s).to eq('/path/to/output.pdf')
          end
        end
      end
    end
  end

  describe "running the CLI" do
    let(:filename) { "my-great-dividers.pdf" }
    let(:args) { Shellwords.split("-w 200 -h 100 -s 2,2 #{filename}") }
    subject { CLI.new(args) }

    it "calls the renderer correctly with the generated dividers and the specified file" do
      sheet = double(Sheet)
      allow(subject).to receive(:sheet) { sheet }

      Dir.mktmpdir do |dir|
        expected_path = File.realdirpath(filename, dir)

        Dir.chdir(dir) do
          expect(Renderer).to receive(:render_to_file).with(sheet, expected_path)

          subject.run
        end
      end
    end
  end
end
