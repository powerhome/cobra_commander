# Change Log

## Unreleased

## Version 0.3.1 - 2018-08-15

* Resolve Bundler API version issue causing breakage building a ComponentTree. PR [#19](https://github.com/powerhome/cobra_commander/pull/19)

## Version 0.3.0 - 2017-10-22

### Added

* Add `name` option for `changes --result` flag that outputs affected component names. PR [#12](https://github.com/powerhome/cobra_commander/pull/12)

* Track package.json `devDependencies` in addition to `dependencies`. PR [#13](https://github.com/powerhome/cobra_commander/pull/13)

* Add `json` option for `changes --result` flag that outputs data as json object. PR [#15](https://github.com/powerhome/cobra_commander/pull/15)

## Version 0.2.0 - 2017-09-01

### Added

* Track javascript components via package.json links. PR [#10](https://github.com/powerhome/cobra_commander/pull/10)

* Alphabetize dependencies in `ls` & `changes` output. PR [#10](https://github.com/powerhome/cobra_commander/pull/10)

* Add component type to `changes` output. PR [#10](https://github.com/powerhome/cobra_commander/pull/10)

## Version 0.1.2 - 2017-05-08

### Fixed

* Functions correctly when executing against a frozen gem bundle (`bundle install --deployment`). PR [#6](https://github.com/powerhome/cobra_commander/pull/6)

## Version 0.1.1 - 2017-05-05

### Fixed

* Rename app from `cbra` to `cobra_commander`. PR [#5](https://github.com/powerhome/cobra_commander/pull/5)

### Added

* Add `changes` functionality. PR [#4](https://github.com/powerhome/cobra_commander/pull/4)

## Version 0.1.0 - 2017-05-03

### Added

* Add `graph` functionality. PR [#3](https://github.com/powerhome/cobra_commander/pull/3)

* Add `ls` functionality. PR [#2](https://github.com/powerhome/cobra_commander/pull/2)

* Implement basic CLI framework. PR [#1](https://github.com/powerhome/cobra_commander/pull/1)
