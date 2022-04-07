# cobra_commander

[![Gem](https://img.shields.io/gem/dv/cobra_commander/stable.svg)](https://rubygems.org/gems/cobra_commander)
[![Gem](https://img.shields.io/gem/v/cobra_commander.svg)](https://rubygems.org/gems/cobra_commander)
[![CI](https://github.com/powerhome/cobra_commander/actions/workflows/ci.yml/badge.svg)](https://github.com/powerhome/cobra_commander/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/7fe0781c18f6923ab753/maintainability)](https://codeclimate.com/github/powerhome/cobra_commander/maintainability)

Tools for working with Component Based Rails Apps (see https://cbra.info). Includes tools for graphing both Ruby and Javascript components in an application and their relationships, as well as selectively testing components based on changes made.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cobra_commander'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cobra_commander

## Usage (cobra help)

```bash
Commands:
  cobra changes [--results=RESULTS] [--branch=BRANCH]  # Prints list of changed files
  cobra exec [component] <command>                     # Executes the command in the context of a given component or set of components. If no component is given executes the command in all components.
  cobra graph [component]                              # Outputs a graph of a given component or umbrella
  cobra help [COMMAND]                                 # Describe available commands or one specific command
  cobra ls [component]                                 # Lists the components in the context of a given component or umbrella
  cobra tree [component]                               # Prints the dependency tree of a given component or umbrella
  cobra version                                        # Prints version

Options:
  -a, [--app=APP]
                             # Default: /Users/chjunior/workspace/power/cobra_commander
      [--js], [--no-js]      # Consider only the JS dependency graph
      [--ruby], [--no-ruby]  # Consider only the Ruby dependency graph
```

### cobra changes

```sh
➜  nitro git:(nova/remove-cobra-commander) be cobra help changes
Usage:
  cobra changes [--results=RESULTS] [--branch=BRANCH]

Options:
  -r, [--results=RESULTS]    # Accepts test, full, name or json
                             # Default: test
  -b, [--branch=BRANCH]      # Specified target to calculate against
                             # Default: master
  -a, [--app=APP]
                             # Default: /Users/chjunior/workspace/power/nitro
      [--js], [--no-js]      # Consider only the JS dependency graph
      [--ruby], [--no-ruby]  # Consider only the Ruby dependency graph

Prints list of changed files
```

### cobra exec

```sh
Usage:
  cobra exec [component] <command>

Options:
      [--dependencies], [--no-dependencies]  # Run the command on each dependency of a given component
      [--dependents], [--no-dependents]      # Run the command on each dependency of a given component
  -a, [--app=APP]
                                             # Default: /Users/chjunior/workspace/power/cobra_commander
      [--js], [--no-js]                      # Consider only the JS dependency graph
      [--ruby], [--no-ruby]                  # Consider only the Ruby dependency graph

Executes the command in the context of a given component or set of components. If no component is given executes the command in all components.
```

### cobra graph

```sh
Usage:
  cobra graph [component]

Options:
  -o, [--output=OUTPUT]      # Output file, accepts .png or .dot
                             # Default: /Users/chjunior/workspace/power/cobra_commander/output.png
  -a, [--app=APP]
                             # Default: /Users/chjunior/workspace/power/cobra_commander
      [--js], [--no-js]      # Consider only the JS dependency graph
      [--ruby], [--no-ruby]  # Consider only the Ruby dependency graph

Outputs a graph of a given component or umbrella
```

### cobra ls

```sh
Usage:
  cobra ls [component]

Options:
  -d, [--dependencies], [--no-dependencies]  # Run the command on each dependency of a given component
  -D, [--dependents], [--no-dependents]      # Run the command on each dependency of a given component
  -t, [--total], [--no-total]                # Prints the total count of components
  -a, [--app=APP]
                                             # Default: /Users/chjunior/workspace/power/cobra_commander
      [--js], [--no-js]                      # Consider only the JS dependency graph
      [--ruby], [--no-ruby]                  # Consider only the Ruby dependency graph

Lists the components in the context of a given component or umbrella
```

### cobra tree

```sh
Usage:
  cobra tree [component]

Options:
  -a, [--app=APP]
                             # Default: /Users/chjunior/workspace/power/cobra_commander
      [--js], [--no-js]      # Consider only the JS dependency graph
      [--ruby], [--no-ruby]  # Consider only the Ruby dependency graph

Prints the dependency tree of a given component or umbrella
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You will also need to install `graphviz` by running `brew install graphviz`. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Bundled App

In order to maintain the features around umbrella apps and specially `changes`, a bundled [`umbrella app repo`](spec/fixtures/app.tgz) is included in this repository. This repo is compacted by `tar`/`gzip` in order to keep isolation, the format was chosen to avoid issues described in https://github.com/swcarpentry/git-novice/issues/272. To avoid the same issues, the workflow for this fixture app is the following:

1. unpack it somewhere outside your repo
1. do your changes and commit (locally only, it doesn't have a remote)
1. from within the app run `tar cfz path/to/cobra/spec/fixtures/app.tgz .`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/powerhome/cobra_commander. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
