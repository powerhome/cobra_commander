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

Then pick the plugins and add them to the cobra group:

```ruby
group :cobra do
  gem 'cobra_commander-ruby'
  gem 'cobra_commander-yarn'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cobra_commander

## Read more

The core package that provides all Cobra functions and models is `cobra_commander`. You can read more about it in its [README file](https://github.com/powerhome/cobra_commander/blob/main/cobra_commander/docs/README.md).

Plugins provide a package source (i.e.: `yarn workspaces`) to compose the components graph of an application. Read more about them here:

  - [cobra_commander-ruby](https://github.com/powerhome/cobra_commander/blob/main/cobra_commander-ruby/docs/README.md)
  - [cobra_commander-yarn](https://github.com/powerhome/cobra_commander/blob/main/cobra_commander-yarn/docs/README.md)

## Usage (cobra help)

```bash
Commands:
  cobra changes [--results=RESULTS] [--branch=BRANCH]  # Prints list of changed files
  cobra exec [components] <command>                    # Executes the command in the context of a given component or set thereof. Defaults to all components.
  cobra graph [component]                              # Outputs a graph of a given component or umbrella
  cobra help [COMMAND]                                 # Describe available commands or one specific command
  cobra ls [components]                                # Lists the components in the context of a given component or umbrella
  cobra tree [component]                               # Prints the dependency tree of a given component or umbrella
  cobra version                                        # Prints version

Options:
  -a, [--app=APP]
                             # Default: /Users/me/myapp
      [--[plugin-key]], [--no-[plugin-key]]  # Consider only the [plugin] dependency graph
```

### cobra changes

```sh
Usage:
  cobra changes [--results=RESULTS] [--branch=BRANCH]

Options:
  -r, [--results=RESULTS]    # Accepts test, full, name or json
                             # Default: test
  -b, [--branch=BRANCH]      # Specified target to calculate against
                             # Default: master
  -a, [--app=APP]
                             # Default: /Users/me/myapp
      [--[plugin-key]], [--no-[plugin-key]]  # Consider only the [plugin] dependency graph

Prints list of changed files
```

### cobra exec

```sh
Usage:
  cobra exec [components] <command>

[components] is all components by default, or a comma separated list of component names (no spaces between)

Options:
      [--affected=AFFECTED]                  # Components affected since given branch [default: main]
  -d, [--dependencies], [--no-dependencies]  # Run the command on each dependency of a given component
  -D, [--dependents], [--no-dependents]      # Run the command on each dependent of a given component
      [--self], [--no-self]                  # Include the own component
                                             # Default: true
  -c, [--concurrency=N]                      # Max number of jobs to run concurrently
                                             # Default: 5
  -i, [--interactive], [--no-interactive]    # Runs in interactive mode to allow the user to inspect the output of each component
                                             # Default: true
  -a, [--app=APP]
                                             # Default: /Users/me/myapp
      [--js], [--no-js]                      # Consider only the JS dependency graph
      [--ruby], [--no-ruby]                  # Consider only the Ruby dependency graph

Executes the command in the context of a given component or set thereof. Defaults to all components.
```

### cobra graph

```sh
Usage:
  cobra graph [component]

Options:
  -o, [--output=OUTPUT]      # Output file, accepts .png or .dot
                             # Default: /Users/me/myapp/output.png
  -a, [--app=APP]
                             # Default: /Users/me/myapp
      [--[plugin-key]], [--no-[plugin-key]]  # Consider only the [plugin] dependency graph

Outputs a graph of a given component or umbrella
```

### cobra ls

```sh
Usage:
  cobra ls [components]

[components] is all components by default, or a comma separated list of component names (no spaces between)

Options:
      [--affected=AFFECTED]                  # Components affected since given branch [default: main]
  -d, [--dependencies], [--no-dependencies]  # Lists all dependencies of a given component
  -D, [--dependents], [--no-dependents]      # Lists all dependents of a given component
      [--self], [--no-self]                  # Include the own component
                                             # Default: true
  -t, [--total], [--no-total]                # Prints the total count of components
  -a, [--app=APP]
                                             # Default: /Users/me/myapp
      [--[plugin-key]], [--no-[plugin-key]]  # Consider only the [plugin] dependency graph

Lists the components in the context of a given component or umbrella
```

### cobra tree

```sh
Usage:
  cobra tree [component]

Options:
  -a, [--app=APP]
                             # Default: /Users/me/myapp
      [--[plugin-key]], [--no-[plugin-key]]  # Consider only the [plugin] dependency graph

Prints the dependency tree of a given component or umbrella
```

## cobra.yml

### Cobra Commands

You can create pre-defined commands to be run in multiple components and packages with `cobra cmd`. An example configuration looks like:

```yaml
sources:
  :ruby:
    commands:
      deps: bundle install
  :js:
    commands:
      deps: yarn install
```

Then running `cobra cmd deps` will run `bundle install` in all ruby packages, and `yarn install` in all JS packages. It will run both commands when the component has both packages.

#### Conditional commands

You can also conditionally disable commands with `if`:

```yaml
sources:
  :ruby:
    commands:
      deps: bundle install
      database:
        if:
          depends_on: database
        run: rake db:refresh
  :js:
    commands:
      deps: yarn install
```

Then running `cobra cmd database` will run `rake db:refresh` in all ruby that depends on the `database` package, and will skip on all other packages.

#### Sequential commands

Sometimes a specific order of commands has to be run to achieve something, that can be done with sequential commands like this:

```yaml
sources:
  :ruby:
    commands:
      deps: bundle install
      database:
        if:
          depends_on: database
        run: rake db:refresh
      test: rake test
      ci:
        - deps
        - database
        - test
  :js:
    commands:
      deps: yarn install
      ci:
        - deps
        - test
```

Then running `cobra cmd ci` will run "deps", then "database", then "test" in all ruby packages. On packages that don't depend on `database` the database job will skip. On JS packages it will run "deps" and then "test".

If any error occur, the execution stops and returns an that job is classified as error.

## Releasing

To release a new version, create a PR updating the version number in `version.rb`, close the version changes in CHANGELOG.md, and create a version tag in master matching the package being released (i.e.: v1.1.1-cobra_commander).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/powerhome/cobra_commander. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
