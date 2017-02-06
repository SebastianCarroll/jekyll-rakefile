# JekyllRake
[![Build Status](https://travis-ci.org/SebastianCarroll/jekyll-rakefile.svg?branch=master)](https://travis-ci.org/SebastianCarroll/jekyll-rakefile)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/jekyll_rake`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll_rake'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll_rake

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jekyll_rake. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## TODO:
* Add method to quickly edit drafts. Currently I have to ls \_drafts, copy latest (requires mouse) and type vim \_drafts/ then copy in the filename. Not the hardest thing in the world but could maybe be simplified with rake edit. Enter for latest or number for other options.
* Combine the README's
