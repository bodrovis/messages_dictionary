# MessagesDictionary

[![Gem Version](https://badge.fury.io/rb/messages_dictionary.svg)](https://badge.fury.io/rb/messages_dictionary)
![CI](https://github.com/bodrovis-learning/messages_dictionary/actions/workflows/ci.yml/badge.svg)
[![Test Coverage](https://codecov.io/gh/bodrovis-learning/messages_dictionary/graph/badge.svg)](https://codecov.io/gh/bodrovis-learning/messages_dictionary)
![Downloads total](https://img.shields.io/gem/dt/messages_dictionary)

This gem started as an educational project for my student. The idea behind this gem is to organize
various messages in a simple key-value format that can be fetched later. Messages support interpolation,
can be stored inside files or passed as hashes (nested hashes are supported as well). Custom fetching rules
can be specified as well.

[Here is my article](https://www.sitepoint.com/learn-ruby-metaprogramming-for-great-good/) describing how this gem was actually written.

This gem requires Ruby 2.7+. Install it by running:

```
gem install messages_dictionary
```

Refer to the next sections to see it in action.

## Use Cases

Wanna see it in action? Some use-cases can be found, in the [Guesser](https://github.com/bodrovis/Guesser) game:

* [Messages are stored inside files](https://github.com/bodrovis/Guesser/tree/master/lib/guesser/messages)
* [Displaying errors](https://github.com/bodrovis/Guesser/blob/master/lib/guesser.rb#L25)
* [Displaying informational messages](https://github.com/bodrovis/Guesser/blob/master/lib/guesser/game.rb#L29)

Another, a bit more complex, use case in the [lessons_indexer gem](https://github.com/bodrovis/lessons_indexer):

* [Messages are stored in a single file](https://github.com/bodrovis/lessons_indexer/blob/master/lib/lessons_indexer/messages/messages.yml)
* [Messenger class equipped with messages_dictionary magic is defined](https://github.com/bodrovis/lessons_indexer/blob/master/lib/lessons_indexer.rb#L7)
* [Other classes simply inherit from it](https://github.com/bodrovis/lessons_indexer/blob/master/lib/lessons_indexer/indexer.rb#L2)
* [Messages are fetched easily](https://github.com/bodrovis/lessons_indexer/blob/master/lib/lessons_indexer/indexer.rb#L45)

## Basic usage

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
    # Or simply
    pou(:welcome)
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

**Please note**, that if your class is named `MyModule::MyClass`, then by default the program will search
for a file named `my_class.yml` inside `my_module` directory. This can be further customized, refer
the "Further Customization" section for more info.

So by saying `pretty_output(:show_result, result: result)` you are fetching a message under the key
`show_result` and replace the `{{result}}` part with the value of the `result` variable. Simple, eh?

## Nesting

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
    pou('nested.value') # => 'Nested value'
  end
end
```

## Indifferent Access

Keys can be passed to the `pou` method as symbols or strings - it does not really matter:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary

  def calculate(a)
    result = a ** 2
    pou(:show_result, result: result)
    # OR
    pou('show_result', result: result)
  end
end
```

## Further Customization

### Specifying File Name and Directory

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

### Providing a custom file loader

By default the gem a messages file in YAML format. However, you might want to use a different format: for example, JSON. In this case you'll have to provide a custom loader:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary file: 'test_file.json', dir: 'my_dir',
                          file_loader: ->(file_path) { JSON.parse(File.read(file_path)) }
end
```

The `:file_loader` option accepts a proc or a lambda that receives a path to your messages file as an argument. This lambda must return a hash object with keys and the corresponding values.

The default value for the `:file_loader` is `->(f) { YAML.load_file(f) }`.

### Specifying Messages Hash

Instead of loading messages from a file, you can pass hash to the `has_messages_dictionary` using `:messages` option:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary messages: {key: 'value'}
end
```

Nesting and all other features are supported as well.

### Specifying Output and Display Method

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

### "Lazy" mode

By default this gem will load all messages from the given file. However, you can enable a "lazy" mode so that messages are not loaded until `pou` or `pretty_output` methods have been called. The "lazy" mode can only be enabled when the `:file` option is provided (in other words, `:lazy` has no effect with the `:messages` setting):

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary lazy: true, file: 'my_file.yml'

  def greet
    pou :hi
  end
end

# At this point no messages are loaded from the given file

obj = MyClass.new

# ... doing some other stuff ...

# Messages are still not loaded at this point!

obj.greet # Now all messages will be loaded from the YAML file
```

### Providing Custom Transformation Logic

Suppose you want to transform your message somehow or even simply return it instead of printing on the screen.
`pretty_output` method accepts an optional block for this purpose:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary

  def greet
    pou(:welcome) do |msg|
      msg.upcase
    end

    # Or simply:

    pou(:welcome, &:upcase)
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
  has_messages_dictionary transform: ->(msg) {msg.upcase}

  def greet
    pou(:welcome)
  end
end

my_object = MyClass.new
my_object.greet # Will return "WELCOME", nothing will be put on the screen
```

Transformation provided per method takes higher precedence than the one provided per class.

**Please note** that by default MessagesDictionary **does not output anything** when you provide transformation
block. This is done to allow more control, because sometimes you may want to fetch a message, but not output
it anywhere (for example, when raising a custom error - see use case [here](https://github.com/bodrovis/Guesser/blob/master/lib/guesser.rb#L25)).

If you do want to output your message after transformation, you have to do it explicitly:

```ruby
def greet
  pou(:welcome) do |msg|
    puts msg.upcase # => Prints "WELCOME"
  end
end
```

### Handling missing keys

By default when a non-existent key is requested, an error will be raised:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary messages: {key: 'value'}

  def greet
    pou :unknown_key # trying to use some unknown key...
  end
end

obj = MyClass.new

obj.greet # KeyError is raised here!
```

However, you can adjust the `:on_key_missing` option and provide a custom proc or lambda to handle all missing keys:

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary messages: {key: 'value'},
                          on_key_missing: ->(key) { key } # We simply return the requested key itself

  def greet
    pou :unknown_key
  end
end

obj = MyClass.new

obj.greet # Prints "unknown_key" to the screen, no errors will be raised
```

So, in the example above we simply return the key itself if it was not found in the messages hash.

## License

Licensed under the [MIT License](https://github.com/bodrovis-learning/messages_dictionary/blob/master/LICENSE).

Copyright (c) 2022 [Ilya Krukowski](http://bodrovis.tech)
