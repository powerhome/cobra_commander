# Change Log

## Version 1.0.1 - 2023-01-05

* Fix Umbrella#resolve unable to resolve a path relative to the project @xjunior [#103](https://github.com/powerhome/cobra_commander/pull/103)

## Version 1.0.0 - 2022-10-15

* Extract Ruby and Yarn package loading to plugins by @xjunior [#87](https://github.com/powerhome/cobra_commander/pull/87)
* Remove unused/broken methods from CobraCommander API by @xjunior [#84](https://github.com/powerhome/cobra_commander/pull/84)
* Ruby sources are not hardcoded to "components" anymore by @xjunior [#85](https://github.com/powerhome/cobra_commander/pull/85)
* Remove graphviz graph in favor of plain dot graph file by @xjunior [#88](https://github.com/powerhome/cobra_commander/pull/88)
* Add license_finder to cobra CI by @xjunior [#89](https://github.com/powerhome/cobra_commander/pull/89)
* Umbrella now "depends" on all packages in Yarn AND Ruby by @xjunior [#90](https://github.com/powerhome/cobra_commander/pull/90)
* Refactor affected to reuse umbrella#resolve by @xjunior [#91](https://github.com/powerhome/cobra_commander/pull/91)
* Umbrella root is not a component by itself anymore by @xjunior [#92](https://github.com/powerhome/cobra_commander/pull/92)
* Move output into CLI by @xjunior [#93](https://github.com/powerhome/cobra_commander/pull/93)
* Simplify Executor and remove Executor::Concurrent by @xjunior [#94](https://github.com/powerhome/cobra_commander/pull/94)

## Version 0.15.1 - 2022-08-23

* Fix `--affected` filter [#82](https://github.com/powerhome/cobra_commander/pull/82)

## Version 0.15.0 - 2022-08-16

* Resolve YARN dependencies based on yarn workspaces info workspaceDependencies [#81](https://github.com/powerhome/cobra_commander/pull/81)
* Add `--affected` filter to `cobra ls` and `cobra exec`, to target all components affected by changes since given branch [#80](https://github.com/powerhome/cobra_commander/pull/80)
* Allows a comma separated list of components on `cobra ls` and `cobra exec` instead of a single component [#79](https://github.com/powerhome/cobra_commander/pull/79)
* Replace standardrb by rubocop-powerhome [#78](https://github.com/powerhome/cobra_commander/pull/78)
* Fix cbra.info links [#70](https://github.com/powerhome/cobra_commander/pull/70)

## Version 0.14.0 - 2021-11-24

* Retain selection on Interactive Printer [#69](https://github.com/powerhome/cobra_commander/pull/69)
* Sorts the interactive UI alphabetically with failures first [#68](https://github.com/powerhome/cobra_commander/pull/68)
* Switch from Rubocop to Standardrb [#67](https://github.com/powerhome/cobra_commander/pull/67)

## Version 0.13.0 - 2021-10-21

* Sorts the interactive UI alphabetically with failures first [#66](https://github.com/powerhome/cobra_commander/pull/66)
* Switch linter to standardrb [#67](https://github.com/powerhome/cobra_commander/pull/67)

## Version 0.12.0 - 2021-09-21

* Add interactive UI and Markdown output to `cobra exec` [#63](https://github.com/powerhome/cobra_commander/pull/63)
* Add `--self` and `--no-self` filters to `cobra exec` and `cobra ls`, defaults to `--self` [#61](https://github.com/powerhome/cobra_commander/pull/61)

## Version 0.11.0 - 2021-04-23

* Add concurrency limit to multi exec [#57](https://github.com/powerhome/cobra_commander/pull/57)
* Ruby 3.0 compatibility [#55](https://github.com/powerhome/cobra_commander/pull/55)

## Version 0.10.0 - 2021-02-25

* Add support for Bundler 2 [#54](https://github.com/powerhome/cobra_commander/pull/54)
* Add support for Ruby 2.7 [#53](https://github.com/powerhome/cobra_commander/pull/53)

## Version 0.9.2 -

* Another fix for binstubs [#51](https://github.com/powerhome/cobra_commander/pull/51)

## Version 0.9.1 -

* Replace bundler encapsulation violation by LockfileParser [#48](https://github.com/powerhome/cobra_commander/pull/48)
* Fix bundle binstubs [#50](https://github.com/powerhome/cobra_commander/pull/50)

## Version 0.9.0 - 2020-08-26

* Add support for parallel task execution to `cobra exec` [#49](https://github.com/powerhome/cobra_commander/pull/49)

## Version 0.8.1 - 2020-07-29

* Fix CobraCommander::Executor when running [`bundler`](https://bundler.io/) based commands (i.e.: `bundle exec rspec`)

## Version 0.8 - 2020-07-21

* Standardize Cobra CLI options
* More powerful filters to all cobra commands (--js, --ruby)
* More powerful filters to cobra ls and exec (--dependencies, --dependents)
* Graphs for components, not just umbrella

## Version 0.7 - 2020-07-08

* Introduces CobraCommander::Umbrella with optimizations for dependency resolution
* Deprecates cobra cache and cache usages

## Version 0.6.1 - 2019-07-05

* Better supports yarn workspaces globbing by delegating to yarn to calculate the list of components rather than re-implementing in Ruby. PR [#34](https://github.com/powerhome/cobra_commander/pull/34)

## Version 0.6.0 - 2019-07-03

* Tracks package.json `workspaces` in addition to `dependencies` and `devDependencies`. PR [#31](https://github.com/powerhome/cobra_commander/pull/31)
* Permits caching the component tree of a project on disk to avoid calculating it repeatedly on subsequent cobra invocations.

## Version 0.5.1 - 2018-10-15

* Fix a bug with dependencies_of where it wouldn't match components further down the list of umbrella's dependencies
* Bumps Thor version from 0.19.4 to a range (< 2.0, >= 0.18.1) compatible with railties

## Version 0.5.0 - 2018-09-20

* Renames `dependencies_of` to `dependents_of`. PR [#25](https://github.com/powerhome/cobra_commander/pull/25)
* Add `dependencies_of` command list the direct and indirect dependencies of one component. PR [#25](https://github.com/powerhome/cobra_commander/pull/25)
* Add `do` command allow executing a command in the context of each component. PR [#26](https://github.com/powerhome/cobra_commander/pull/26)

## Version 0.4.0 - 2018-09-06

* Add `dependencies_of` command to permit listing or counting the dependencies of a particular component. PR [#24](https://github.com/powerhome/cobra_commander/pull/24)
* Fix indentation of tree output. PR [#23](https://github.com/powerhome/cobra_commander/pull/23)

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
