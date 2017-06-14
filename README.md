# BoxDividers

Generates PDFs of the dividers for my Lego storage box system.

You can use it as a library or with the supplied `box-dividers` command

## Installation

Run

    $ gem install box_dividers

to just install it so you run the `box-dividers` command

To use it as a library add this line to your application's Gemfile:

```ruby
gem 'box_dividers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install box_dividers

## Usage

Set sheet maximum size to 1000mm x 600mm and write to `output-file.pdf`
    $ box-dividers -w 1000 -h 600 output-file.pdf

Set sheet maximum size to 1000mm x 600mm and write to `output-file.pdf`
    $ box-dividers -w 1000 -h 600 output-file.pdf

Set sheet maximum size to 1000mm x 600mm, generate 10x4, 5x4, & 4x4 dividers, and write to `output-file.pdf`
    $ box-dividers -w 1000 -h 600 -s "10,4 5,4 4,4" output-file.pdf

You can also run `box-dividers --help` for a quick summary

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fidothe/box_dividers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

