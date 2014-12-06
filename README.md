# PagerdutyCli

A Ruby-based CLI to PagerDuty. Supports triggers and resolves.

Inspired by Pinterest's Python implementation:
https://github.com/pinterest/pagerduty-monit

Requires Ruby >= 1.9.3.

## Installation

Add to your Gemfile:

```ruby
gem 'pagerduty_cli'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pagerduty_cli

## Usage

Trigger an event with
```
pagerduty-trigger -e EVENT_NAME
```

See all options with:
```
pagerduty-trigger -h
```

Resolve an event with
```
pagerduty-resolve -e EVENT_NAME
```
See all options with:
```
pagerduty-resolve -h
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pagerduty_cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
