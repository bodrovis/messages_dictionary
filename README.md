# PrettyOuputter

***this is still in WP!!!***

## Usage

```ruby
class MyClass
  include PrettyOutputter

  def test(a)
    result = a * 2
    render(:other_msg, value: result)
    # => "Your value is 4"
  end
end

obj = MyClass.new
obj.test(2)
```

Create another file called `MyClass.yml` with messages:

```yaml
my_msg: "Some message"
other_msg: "Your value is {{value}}"
```

## License

Licensed under the [MIT License](https://github.com/bodrovis-learning/PrettyOutputter/blob/master/LICENSE).

Copyright (c) 2015 [Ilya Bodrov](http://radiant-wind.com)