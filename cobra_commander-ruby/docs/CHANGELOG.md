# Change Log

## Version 1.1.0 - 2026-06-09

* Enhance command execution from the ruby source via `Bundle#around_command`: it wraps the run in `Bundler.with_unbundled_env` and yields `BUNDLE_APP_CONFIG` pointing at the umbrella's `.bundle` directory, so nested `bundle` calls resolve their config from the umbrella. Only the ruby plugin applies this isolation.
* Raise the minimum supported Ruby version to 3.2 and expand CI to cover Ruby 4.0.

## Version 1.0.0 - 2022-10-15

Initial extraction of the ruby plugin from `cobra_commander`.
