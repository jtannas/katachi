---
sidebar_position: 5
---

# Hash Comparison Design

Katachi's hash comparison is inspired by OpenAPI (formerly Swagger) specs.

Specifically, it's inspired by all the ways that I've consistently made
goofy mistakes when writing them.

Here's the story of how they led to the design of Katachi's hash comparison:

## 3 Different Versions Of Nullable

OpenAPI has handled `null` values a few different ways over the years.

- OpenAPI 2.0 (Swagger) didn't support `null` values at all, so people used `x-nullable: true`
- OpenAPI 3.0 made this official by supporting `nullable: true`
- OpenAPI 3.1 found a much simpler way by treating `null` as a type: `type: ["string", "null"]`

I like the 3.1 approach of treating `null` as just another possible type.
I decided to take it further with Ruby's tools for inspecting types.
We don't need the `type` description for fields -- Ruby can just tell us what type it is!

We can just literally use `nil` as a possible value!

All it takes is supporting a hash value being multiple types (e.g. `nil` or `String`).

That led to the creation of `Katachi::AnyOf`.

```ruby
shape = { email: AnyOf[String, nil] }
```

## OpenAPI Keys Are Optional By Default

> In the following description, if a field is not explicitly REQUIRED
> or described with a MUST or SHALL, it can be considered OPTIONAL.
>
> \- [OpenAPI 3.1.1 Specification](https://spec.openapis.org/oas/v3.1.1)

OpenAPI's decision to make all object keys optional by default has
caught repeatedly.

> "What do you mean the API response is empty?!? I tested it against the spec!"
>
> \- Me, multiple times

I wanted to prevent people from falling into that trap, so Katachi has all the keys required by default. The comparison logic would be a simple set difference:

```ruby
    missing_keys = shape.keys - value.keys
```

## OpenAPI Extra Keys Are Allowed By Default

> Additional properties are allowed by default in OpenAPI.
> To enforce maximum strictness use additionalProperties: false to block all arbitrary data.
>
> \- [ApiMatic/OpenAPI/additionalProperties](https://www.apimatic.io/openapi/additionalproperties)

On the flip side, OpenAPI's decision to allow extra keys in an object by default has also
caught me multiple times.

> "Why is the API response so big?!? It's nowhere near that bloated in the spec!"
>
> \- Me, multiple times

Again, my chosen solution is to disallow extra keys by default.The comparison logic would be a simple set difference:

```ruby
    extra_keys = value.keys - shape.keys
```

... Right? (cue foreboding music)

## Sane Defaults, But Inflexible

With those decisions, the core design is starting to take shape:

- All keys are required
- No extra keys are allowed
- `nil` is just another possible value; no special syntax needed

That's a good set of defaults, but it's not flexible enough for most use cases.

- Keys can be optional sometimes.
- Extra keys can be allowed sometimes.
- Sometimes you only want to test a few keys.

I needed to add a way to make keys optional and a way to allow extra keys.

## Allowing Optional Keys

I wanted users to not have to look up a special syntax or use a proprietary class for when
they want a hash key to be optional.

Borrowing from OpenAPI 3.1's handling of `null`, I added a special value `:$undefined` to indicate that a key can be missing without the object being invalid.

It's really convenient for users, but it comes with a new issue. We can no longer blindly assume that every key in the shape is required.

```diff
    missing_keys = shape.keys - value.keys
+   missing_keys -= optional_keys()
```

## Allowing Extra Keys

Again, I wanted to make this easy for users without having to look up a special syntax. I eventually stumbled upon the idea of letting users add `Object => Object` to match any key-value pair.

e.g. Checking just the email

```ruby
compare(
    value: User.last.attributes,
    shape: {
        "email" => request.params[:email],
        Object => Object,
    },
)
```

It looks a bit weird to have `Object` as a hash key, but it's perfectly valid Ruby.

```diff
    extra_keys = value.keys - shape.keys
+   extra_keys -= matching_keys()
```

## Matching Priority

The problem with `Object => Object` is that it will match <ins>**literally any key-value pair**</ins>.

That makes it impossible for the hash comparison to not find a valid match.

So I had to put in a way for specific key matches (e.g. `email`) to take priority
over more general matches. That led to a whole branch of code for checking for exact key matches
between the shape and the value.

## Non-Required Keys

Another problem with using `Object => Object` for extra keys is that it's means that a key defined in the shape isn't necessarily required in the value.

If the comparison threw a `:hash_mismatch` when the user's hash didn't literally have a key-value pair `Object => Object`, that'd ruin that whole feature.

The lazy solution was to just ignore `Object => Object`, but what if users want to be a bit stricter about their extra keys?

- `Symbol => String` is a normal data structure to enforce.
- `:$email => User` is an excellent description for a lookup hash.

We need to figure out a way to distinguish between shape keys that are required and which ones are more general matching rules.

```diff
    missing_keys = shape.keys - value.keys
    missing_keys -= optional_keys()
+   missing_keys -= matcher_keys()
```

To keep things consistent, the solution ended up being to use the same `compare` algorithm on the hash keys as we do on any other value.

## Diagnostic Labels

All of these changes made the comparison logic much more complex than I had anticipated.
What really brought it into a whole new level of complexity was the need to provide diagnostic labels for each comparison. Telling users "your hash isn't a match and we're not telling you why" is a frustrating user experience.

It needs to report:

- Which keys were missing
- Which keys were extra
- Which values didn't match

That's too much information to stuff into a flat return value - it needs to be a nested structure where each comparison reports all the factors that led to the match or mismatch.

## The Final Design

That all combines to the general flow of hash comparison in Katachi:

```yaml
Definitions:
    VHash: Value Hash
    SHash: Shape Hash
    VKey: Value Key
    SKey: Shape Key
    VValue: Value Value
    SValue: Shape Value

Katachi::Result: Did the VHash match the SHash?
  missing_keys: Are all keys in the shape present in the value?
    {each SKey comparisons}:
        - Determine if the SKey is required or optional.
            - Is the SKey a general matching rule?
                - Yes: Consider it optional.
                - No: It's a specific key. Does the corresponding SValue contain :$undefined?
                    - Yes: SKey is optional.
                    - No: SKey is required.
        - Check if the SKey is present in the VHash.
            - Identical: label as exact match.
            - Match Any: label as match.
            - Key Not required: label as optional.
            - Else: label as missing key.
  extra_keys: Are there any VKeys that aren't in the SHash?
    {each VKey comparisons}:
        - Is the VKey exactly in the SHash?
            - Yes: label it as an exact match.
            - No: Does it match any SKey matchers?
                - Compare each SKey matcher to the VKey.
                    - Yes: label that comparison as a general match.
                    - No: label that comparison as a mismatch.
                - Did any of them match?
                    - Yes: label it as a match.
                    - No: label it as an extra key.
  values: Do the VValues match the corresponding SValues in the shape?
    {each VKey comparisons}:
        - Is the VKey exactly in the SHash?
            - Yes: Compare the corresponding VValue to the SValue.
                - Identical: label VValue as an exact match.
                - Match: label VValue as a match.
                - No Match: label VValue as a mismatch.
            - No: Does the VKey match any SKey matching rules?
                - Yes: Compare the corresponding VValue to the SValue.
                    - Identical: label as exact match.
                    - Match: label as match.
                    - No Match: label as mismatch.
                - No: label as mismatch.
```

## Conclusion

Yeah...

It was rough to code...

But it makes for an awesome user experience :)

```ruby
shape = {
    :$uuid => {
        email: :$email,
        first_name: String,
        last_name: String,
        preferred_name: AnyOf[String, nil],
        admin_only_information: AnyOf[{Symbol => String}, :$undefined],
        Symbol => Object,
    },
}
expect(value: api_response.body, shape:).to be_match
```
