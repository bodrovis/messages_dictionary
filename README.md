# PrettyOuputter

## Usage

```ruby
class MyClass
  include Outputter

  def test
    render(:other_msg)
  end
end

class MyOtherClass
  include Outputter
end

obj = MyClass.new
obj.test
```

## License

Licensed under the [MIT License]().

Copyright (c) 2015 [Ilya Bodrov](http://radiant-wind.com)