# Contributing

## Philosophy

To guide development and explain "why was it done this way?" we have a [Philosophy](./Philosophy.md) document.
Contributions should aim to follow the principles outlined there.

## Development

After checking out the repo, run `rake setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `rake console` for an interactive prompt that will allow you to experiment.

In general, we want the `Rakefile` to be the source of truth for all tasks. If you find yourself manually running a task more than once, consider adding it to the `Rakefile`.

We don't have a release process yet, but it's coming soon!

## Contributing

Bug reports and pull requests are welcome. Feature requests are welcome, but please open an issue first to discuss what you would like to change.

Everyone interacting in the Katachi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](./CodeOfConduct.md).

# Versioning

This gem uses [Epoch Semantic Versioning](https://antfu.me/posts/epoch-semver).

The format is: `EPOCH.MAJOR.MINOR.PATCH`

> - EPOCH: Increment when you make significant or groundbreaking changes.
> - MAJOR: Increment when you make minor incompatible API changes.
> - MINOR: Increment when you add functionality in a backwards-compatible manner.
> - PATCH: Increment when you make backwards-compatible bug fixes.

Until we reach EPOCH 1, we will be in a state of rapid development.
Breaking changes will still be communicated via major versions, but
they may be fairly large in scope and number.
