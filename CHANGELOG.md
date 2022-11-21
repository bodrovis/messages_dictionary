# Changelog

## 2.0.0

This is a major re-write of the gem. All core features stay the same and there should not be any breaking changes, except for one thing: you should not use "destructive" methods when transforming your messages.

Previously you could say:

```ruby
def greet
  pou(:welcome) do |msg|
    puts msg.upcase!
  end
end
```

Now it's recommended to use "safe" `upcase` method:

```ruby
def greet
  pou(:welcome) do |msg|
    puts msg.upcase
  end
end
```