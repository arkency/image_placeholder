# ImagePlaceholder

Rack middleware that intercepts not found image requests and replaces them with [placeholders](https://www.hanselman.com/blog/TheInternetsBestPlaceholderImageSitesForWebDevelopment.aspx). Useful for your development data references uploaded images but static files are no longer where they're supposed to be 😅.

[![Build Status](https://travis-ci.org/arkency/image_placeholder.svg?branch=master)](https://travis-ci.org/arkency/image_placeholder)
[![Gem Version](https://badge.fury.io/rb/image_placeholder.svg)](https://badge.fury.io/rb/image_placeholder)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'image_placeholder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install image_placeholder

## Usage

Simplest usage, with default values. Extensions `jpg` and `png` are matched and the placeholder image has 100x100 dimension:

```ruby
# config/environments/development.rb

Rails.application.configure do
  config.middleware.use ImagePlaceholder::Middleware
end
```

Providing your own list of image extensions:

```ruby
# config/environments/development.rb

Rails.application.configure do
  config.middleware.use ImagePlaceholder::Middleware, image_extensions: %w(jpg jpeg png webp gif)
end
```

Providing your own sizes per request path. First regular expression match wins, so start with most specific ones:

```ruby
# config/environments/development.rb

Rails.application.configure do
  config.middleware.use ImagePlaceholder::Middleware, size_pattern: {
    %r{/uploads/.*/s_[0-9]+\.[a-z]{3}$}  => 200,  # /uploads/product/cover/42/s_9781467775687.jpg
    %r{/uploads/.*/xl_[0-9]+\.[a-z]{3}$} => 750,  # /uploads/product/cover/42/xl_9781467775687.jpg
    %r{.*} => 1024,                               # /uploads/random/spanish_inquisition.png
  }
end
```

You can even change placeholder image host, if for example you prefer [fillmurray](https://fillmurray.com):

```ruby
Rails.application.configure do
  config.middleware.use ImagePlaceholder::Middleware, size_pattern: { /.*/ => '320/320' }, host: 'fillmurray.com'
end
```

Last but not least, this middleware can be used with any Rack application:

```ruby
# config.ru
use ImagePlaceholder::Middleware, size_pattern: { /.*/ => '320/320' }, host: 'fillmurray.com'
run YourRackApp
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arkency/image_placeholder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About

<img src="http://arkency.com/images/arkency.png" alt="Arkency" width="14%" align="left" />

This gem is funded and maintained by [Arkency](http://blog.arkency.com). Check out our other [open-source projects](https://github.com/arkency).