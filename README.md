# cobra_commander

[![Gem](https://img.shields.io/gem/dv/cobra_commander/stable.svg)](https://rubygems.org/gems/cobra_commander)
[![Gem](https://img.shields.io/gem/v/cobra_commander.svg)](https://rubygems.org/gems/cobra_commander)
[![Travis](https://img.shields.io/travis/powerhome/cobra_commander.svg)](https://travis-ci.org/powerhome/cobra_commander)

Tools for working with Component Based Rails Apps (see http://shageman.github.io/cbra.info/). Includes tools for graphing both Ruby and Javascript components in an application and their relationships, as well as selectively testing components based on changes made.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cobra_commander'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cobra_commander

## Usage

```bash
Commands:
  cobra changes APP_PATH [--results=RESULTS] [--branch=BRANCH]  # Prints list of changed files
  cobra graph APP_PATH [--format=FORMAT]                        # Outputs graph
  cobra help [COMMAND]                                          # Describe available commands or one specific command
  cobra ls APP_PATH                                             # Prints tree of components for an app
  cobra version                                                 # Prints version
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/powerhome/cobra_commander. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
