# Minitest Integration

We provide both custom assertions and expectations for Minitest.

```ruby title="Minitest Integration"
require 'katachi/minitest'

shape = [1, 2, 3]
assert_shape(shape, [1, 2, 3])
refute_shape(shape, [1, 2, 4])

_([1, 2, 3]).must_match_shape(shape)
_([1, 2, 4]).wont_match_shape(shape)
```
