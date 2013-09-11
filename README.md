# SMSd

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'smsd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smsd

## Usage

```ruby
#!/usr/bin/env ruby

require 'smsd'
require 'net/http'

cli = SMSd::CLI.new(ARGV) do
  machine = SMSd::AnsweringMachine.new(I18n.t(:default_answer))

  machine.add_action(/hello/i, 'Hello !!')
  machine.add_action(/what/i) do |from, to, message|
    "The phone number #{from} sent '#{message}' to #{to}"
  end
  machine.add_action(/myip/i) do
    Net::HTTP.get('icanhazip.com', '/').chomp
  end
end

cli.run
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

SMSd is released under AGPLv3 license. Copyright (c) 2013 La Fourmi Immo
