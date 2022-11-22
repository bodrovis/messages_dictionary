# Changelog

## Unreleased

* `pou` and `pretty_output` are now available inside class methods
* `DICTIONARY_CONF` now contains an instance of the `Config` class that takes care of all configuration options
* Added `lazy` option that enables lazy loading
* Added `on_key_missing` option which is set to `:raise` by default. You can pass a proc or a lambda to this option in order to provide a custom handler that fires when a given key cannot be found.
* Added `file_loader` option to handle custom file loading

## 2.0.0 (22-Nov-2022)

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