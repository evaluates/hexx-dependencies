Hexx::Dependencies
==================

[![Gem Version](https://img.shields.io/gem/v/hexx-dependencies.svg?style=flat)][gem]
[![Build Status](https://img.shields.io/travis/nepalez/hexx-dependencies/master.svg?style=flat)][travis]
[![Dependency Status](https://img.shields.io/gemnasium/nepalez/hexx-dependencies.svg?style=flat)][gemnasium]
[![Code Climate](https://img.shields.io/codeclimate/github/nepalez/hexx-dependencies.svg?style=flat)][codeclimate]
[![Coverage](https://img.shields.io/coveralls/nepalez/hexx-dependencies.svg?style=flat)][coveralls]

[codeclimate]: https://codeclimate.com/github/nepalez/hexx-dependencies
[coveralls]: https://coveralls.io/r/nepalez/hexx-dependencies
[gem]: https://rubygems.org/gems/hexx-dependencies
[gemnasium]: https://gemnasium.com/nepalez/hexx-dependencies
[travis]: https://travis-ci.org/nepalez/hexx-dependencies

Scaffolds the current project's dependency from a variable, defined outside.

The module is used inside the [hexx] collection of scaffolders.

[hexx]: https://github.com/nepalez/hexx

Usage
-----

Suppose we need the `user_class` dependency that should be initialized by dummy application as `User` taken from the external `users` module.

The dependency should be called as a core module getter:

```ruby
MyModule.user_class # => User from 'users' gem (in the test environment)
```

To do it start the scaffolder:

```ruby
Hexx::Dependencies::CLI.start %w(user_class -i User -g users) 
```

Results
-------

At first the scaffolder provides base loader mechanism (if it is absent):

* dummy app `spec/dummy`.
* dummy loader `spec/spec_helper.rb`.
* the module configurator `lib/my_module/configurator.rb`.
* the module initializer `spec/dummy/config/initializers/my_module.rb`.
* the configurator loaders from `lib/my_module.rb`.

See the *Loading Order* part below for details how it works.

Then the scaffolder adds required settings:

* `user_class` attribute in `lib/my_module/configurator.rb`.
* `users` development dependency in the Gemfile.
* `users` loader in the `spec/dummy/initializers.rb`.
* `user_class = User` injection in the `spec/dummy/initializers.rb`.

### Loading Order

The module is loaded in the following order:

* The dummy application takes the control:

```ruby
# spec/spec_helper.rb
require_relative "dummy/lib/dummy"
```

The dummy app:
* sets the pointer to initializers folder `ENV['PATH_TO_INITIALIZERS']`.
* gives control to the module.

```ruby
# spec/dummy/lib/dummy.rb
ENV['PATH_TO_INITIALIZERS'] = File.expand_path(
  "../../config/initializers", __FILE__
)
require "my_module"
```

`lib/my_module.rb`:
* declares its `Configurator`.
* takes its own initializers from dummy `config/initializers` folder.
* loads the rest of the code.

```ruby
# lib/my_module.rb
require_relative "my_module/configurator"
load File.join(ENV['PATH_TO_INITIALIZERS'], "my_module.rb")
# ...loads the rest of application

# lib/my_module/configurator.rb
module MyModule
  class << self
    def configure
      instance_eval(yield) if block_given?
    end

    attr_accessor :user_class
  end
end

# spec/dummy/config/initializers/my_module.rb
require "users"

MyModule.configure do |config|
  user_class = User  
end
```

Installation
------------

Add this line to your application's Gemfile:

```ruby
# Gemfile
gem "hexx-dependencies"
```

Then execute:

```
bundle
```

Or add it manually:

```
gem install hexx-dependencies
```

Compatibility
-------------

Tested under rubies compatible to MRI 2.0 API:
* MRI 2.0+
* Rubinius 2+ (2.0+ modes)
* JRuby-head (9000) (2.0+ modes)

Uses [RSpec] 3.0+ for testing and [hexx-suit] for dev/test tools collection.

[hexx-suit]: https://github.com/nepalez/hexx-suit

Contributing
------------

* Fork the project.
* Read the [STYLEGUIDE](config/metrics/STYLEGUIDE).
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version
  in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------

See the [MIT LICENSE](LICENSE).
