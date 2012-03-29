# Critique

**WIP**

critiques your code... simple memory profiling with easy setup (e.g., no need to patch ruby).

## Installation

Add this line to your application's Gemfile:

    gem 'critique'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install critique

## Usage

given your code:

    class ExampleClass
      include Critique

      def method
        critique do
          # code
        end
      end
    end

enable Critique:

    Critique.enable! # e.g., in a Rails initializer
    Critique.logger = $stdout
    # or...
    # Critique.logger = 'path/to/log'
    # Critique.logger = Rails.logger

run & view logs:

    X  ExampleClass#method --> ... used: 6.60 GB free: 1.59 GB
    X  ExampleClass#method <-- ... used: 6.62 GB free: 1.57 GB delta: +0.32%


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
