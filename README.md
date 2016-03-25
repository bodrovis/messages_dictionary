# MessagesDictionary
[![Gem Version](https://badge.fury.io/rb/messages_dictionary.svg)](https://badge.fury.io/rb/messages_dictionary)
[![Build Status](https://travis-ci.org/bodrovis-learning/messages_dictionary.svg?branch=master)](https://travis-ci.org/bodrovis-learning/messages_dictionary)
[![Code Climate](https://codeclimate.com/github/bodrovis-learning/messages_dictionary/badges/gpa.svg)](https://codeclimate.com/github/bodrovis-learning/messages_dictionary)
[![Dependency Status](https://gemnasium.com/bodrovis-learning/messages_dictionary.svg)](https://gemnasium.com/bodrovis-learning/messages_dictionary)

This gem was created as an educational project for my student. The idea behind this gem is to organize
various messages in a simple key-value format that can be fetched later. Messages support interpolation,
can be stored inside files or passed as hashes (nested hashes are supported as well). Custom fetching rules
can be specified as well.

Some use-cases can be found, for example, in the [Guesser](https://github.com/bodrovis/Guesser) game:

* [Messages are stored inside files](https://github.com/bodrovis/Guesser/tree/master/lib/guesser/messages)
* [Displaying errors](https://github.com/bodrovis/Guesser/blob/master/lib/guesser.rb#L25)
* [Displaying informational messages](https://github.com/bodrovis/Guesser/blob/master/lib/guesser/game.rb#L29)

Install it

    gem install messages_dictionary

and refer to the next section to see it in action.

## Usage

### Basic Example

Suppose you have the following program:

```ruby
class MyClass
  def calculate(a)
    result = a ** 2
    puts "The result is #{result}"
  end
end

class MyOtherClass
  def some_action(a, b)
    puts "The first value is #{a}, the second is #{b}"
  end

  def greet
    puts "Welcome!"
  end
end
```

These messages are scattered all over the program and can be hard to maintain. With `messages_dictionary` you can transform it into

```ruby
require 'messages_dictionary' # For brevity this line will be omitted in other examples

class MyClass
  include MessagesDictionary
  has_messages_dictionary

  def calculate(a)
    result = a ** 2
    pretty_output(:show_result, result: result)
  end
end

class MyOtherClass
  include MessagesDictionary
  has_messages_dictionary

  def some_action(a, b)
    pretty_output(:show_values, first: a, second: b)
  end

  def greet
    pretty_output(:welcome)
  end
end
```

The only thing you have to do is create two *.yml* files named after your classes:

*my_class.yml*

```yaml
show_result: "The result is {{result}}"
```

*my_other_class.yml*

```yaml
show_values: "The first value is {{a}}, the second is {{b}}"
welcome: "Welcome!"
```

So by saying `pretty_output(:show_result, result: result)` you are fetching a message under the key
`show_result` and replace the `{{result}}` part with the value of the `result` variable. Simple, eh?

### Nesting

MessagesDictionary supports nesting (similar to localization files in Rails):

*my_class.yml*

```yaml
show_result: "The result is {{result}}"
nested:
  value: 'Nested value'
```

Nested messages can be easily accessed with dot notation:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary

  def do_something
    pretty_output('nested.value') # => 'Nested value'
  end
end
```

### Indifferent Access

Keys can be passed to the `pretty_output` method as symbols or strings - it does not really matter:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary

  def calculate(a)
    result = a ** 2
    pretty_output(:show_result, result: result)
    # OR
    pretty_output('show_result', result: result)
  end
end
```

### Further Customization

#### Specifying File Name and Directory

By default `messages_dictionary` will search for a *.yml* file named after your class (converted to snake case,
so for the `MyClass` the file should be named *my_class.yml*)
inside the same directory. However, this behavior can be easily changed with the following options:

* `:file` (`string`) - specifies the file name to load messages from (extension has to be provided).
* `:dir` (`string`) - specifies the directory to load file from.

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary file: 'some_file.yml', dir: 'C:\my_docs'
end
```

Both of these options are not mandatory.

#### Specifying Messages Hash

Instead of loading messages from a file, you can pass hash to the `has_messages_dictionary` using `:messages` option:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary messages: {key: 'value'}
end
```

Nesting and all other features are supported as well.

#### Specifying Output and Display Method

By default all messages will be outputted to `STDOUT` using `puts` method, however this can be changed:

* `:output` (`object`) - specify your own output. The object you provide has to implement `puts` method
or any other method you provide for the `:method` option.
* `:method` (`symbol` or `string`) - specify method to use (like `warn` or `abort`, for example).

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary output: STDOUT, method: :warn
end
```

#### Providing Custom Transformation Logic

Suppose you want to transform your message somehow or even simply return it instead of printing on the screen.
`pretty_output` method accepts an optional block for this purpose:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary

  def greet
    pretty_output(:welcome) do |msg|
      msg.upcase!
    end
  end
end

my_object = MyClass.new
my_object.greet # Will return "WELCOME", nothing will be put on the screen
```

You can also specify transformation logic globally by assigning a procedure or lambda to the `:transform`
option:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary transform: ->(msg) {msg.upcase!}

  def greet
    pretty_output(:welcome)
  end
end

my_object = MyClass.new
my_object.greet # Will return "WELCOME", nothing will be put on the screen
```

**Please note** that by default MessagesDictionary **does not output anything** when you provide transformation
block. This is done to allow more control, because sometimes you may want to fetch a message, but not output
it anywhere (for example, when raising a custom error - see use case [here](https://github.com/bodrovis/Guesser/blob/master/lib/guesser.rb#L25)).

If you do want to output your message after transformation, you have to do it explicitly:

```ruby
  def greet
    pretty_output(:welcome) do |msg|
      msg.upcase!
      puts msg # => Prints "WELCOME"
    end
  end
```

## License

Licensed under the [MIT License](https://github.com/bodrovis-learning/messages_dictionary/blob/master/LICENSE).

Copyright (c) 2016 [Ilya Bodrov](http://radiant-wind.com)