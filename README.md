# Sunspot::Resque

This gem employs solution provided by [Andrew Evans](http://stdout.heyzap.com/2011/08/17/sunspot-resque-session-proxy/).

Rails 3 only gem.

## Installation

Add this line to your application's Gemfile:

    gem 'sunspot_resque'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sunspot_resque

## Usage

After adding this gem to the `Gemfile` your `Sunspot.session` will be automatically proxied.
It's disabled though for all rake tasks as it's what you'd want in most cases.
In all others you can use `DISABLE_SUNSPOT_RESQUE` ENV variable to `false`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

* Sijawusz Pur Rahnama
* Andrew Evans
