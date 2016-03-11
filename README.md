# MessagesDictionary

This gem was created as an educational project for my student. The idea behind this gem is to organize
various messages in a simple key-value format that can be fetched later. Messages support interpolation,
can be stored inside files or passed as hashes (nested hashes are supported as well). Custom fetching rules
can be specified as well.

Refer to the next section to see it in action.

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

With `messages_dictionary` you can transform it into

```ruby
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

### Further Customization

#### Specifying File Name and Directory

By default `messages_dictionary` will search for a *.yml* file named after your class (converted snake case)
inside the same directory. However, this behavior can be easily changed with the following options:

* `:file` (`string`) - specifies the file name to load messages from (extension has to be provided).
* `:dir` (`string`) - specifies the directory to load file from.

```ruby
class MyClass
  include MessagesDictionary
  has_messages_dictionary file: 'some_file.yml', dir: 'C:\my_docs'
end
```

#### Specifying Output and Display Method

By default all messages will be outputted to `STDOUT` using `puts` method, however this can be changed as well:

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

Suppose you want to transform your message somehow or even return it instead of printing on the screen.
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

## License

Licensed under the [MIT License](https://github.com/bodrovis-learning/messages_dictionary/blob/master/LICENSE).

Copyright (c) 2016 [Ilya Bodrov](http://radiant-wind.com)