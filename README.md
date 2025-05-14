![Gem Version](https://img.shields.io/gem/v/katachi)
[![Coverage Status](https://coveralls.io/repos/github/jtannas/katachi/badge.svg?branch=main)](https://coveralls.io/github/jtannas/katachi?branch=main)
![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/jtannas/katachi)

# Katachi

A tool for describing and validating objects as intuitively as possible.

```ruby
Katachi.compare(
    value: {name: 'John', age: 30},
    shape: {name: String, age: Integer}
).match? # => true
```

Find out more at [jtannas.github.io/katachi](https://jtannas.github.io/katachi/).

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
$ bundle add katachi
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
$ gem install katachi
```

## Future Features Under Consideration

- [ ] More shapes (e.g. `:$email`, `:$url`, `:$iso_8601`)
- [ ] More "matching modifiers" (e.g. `all_of`, `one_of`, `none_of`)
- [ ] More output formats (e.g. `to_json`, `to_hash`, etc...)
- [ ] Custom shape codes (e.g. `:email_is_invalid`)
- [ ] Rails integration (e.g. `validates_shape_of`)
- [ ] Shape-to-TypeScript conversion
- [ ] Shape-to-Zod conversion
- [ ] Shape-to-OpenAPI conversion
- [ ] `katachi-rspec-api` for testing+documenting APIs in a way inspired by [RSwag](https://github.com/rswag/rswag)

## Development and Contributing

See [CONTRIBUTING.md](./docs/Contributing/Contributing.md) for information on how to contribute to Katachi.
Alternatively, you can check out the [Contributing](https://jtannas.github.io/katachi/docs/Contributing) section on the documentation site.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
