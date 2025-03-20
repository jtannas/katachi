---
sidebar_position: 1
---

# Getting Started

Install the gem and add to the application's Gemfile by executing:

```bash
$ bundle add katachi
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
$ gem install katachi
```

From there, the gem can be required in the application by executing:

```ruby
require 'katachi'
```

There are only 3 methods that Katachi provides. It's all about how you use them.

1. `Katachi.compare(value:, shape:)` to compare a value against a shape.
2. `Katachi.any_of(shapes*)` for allowing a value to match any of the shapes.
3. `Katachi.add_shape(name, shape)` to add a custom shape.

For more information on how to use these methods, check out the [Features](/docs/Features) section.
