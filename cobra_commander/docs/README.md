# cobra_commander

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Bundled App

In order to maintain the features around umbrella apps and specially `changes`, a bundled [`umbrella app repo`](spec/fixtures/modified-app.tgz) is included in this repository. This repo is compacted by `tar`/`gzip` in order to keep isolation, the format was chosen to avoid issues described in https://github.com/swcarpentry/git-novice/issues/272. To avoid the same issues, the workflow for this fixture modified-app is the following:

1. unpack it somewhere outside your repo
1. do your changes and commit (locally only, it doesn't have a remote)
1. from within the app run `tar cfz path/to/cobra/spec/fixtures/modified-app.tgz .`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/powerhome/cobra_commander. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
