# Frequently Asked Questions

## Is this safe for production use?

While Katachi is still a young project, [we're maniacs about reliable tools](https://earthly.dev/blog/idiots-and-maniacs/).

- The comparison logic is feature complete.
- There are **zero** runtime dependencies.
- There are **zero** hidden side effects.
- Our test suite requires **100%** coverage by line and by logic branch.
- The only shared state in the project is the `Katachi::Shape` library.
- We have a strict semantic versioning policy, using `epoch.major.minor.patch` versioning.
  - Every breaking changes will receive at least a major version bump.
  - Epoch versioning will be more for "marketing level events" (eg. "Katachi 1.0 is released!").
  - a.k.a. No equivocating about "is this worth a major version bump?"
- For code quality tools, we threw the kitchen sink at it:
  - [Rubocop](https://github.com/rubocop/rubocop) Formatting & Linting
  - [RSpec](https://rspec.info/) Full Test Suite
  - [Minitest](https://github.com/minitest/minitest) Adapter Testing
  - [CSpell](https://cspell.org/) Spell Checking
  - [CodeRabbit](https://www.coderabbit.ai/) AI Code Review
  - [Renovate](https://docs.renovatebot.com/) Automated DevTool Updates
  - [CodeQL](https://securitylab.github.com/tools/codeql) Security Scanning

## Why should I use this instead of _tool_name_here_?

Honestly?

Katachi is designed to be a foundation for other integrations.

If there's a tool you'd like to see Katachi integrated with, please let us know!

We have `RSpec` and `Minitest` integrations and we think they're pretty cool, but they were never the finish line.

We're excited to see what else we can build on top of Katachi.

Here are some of the ideas already floating around:

- `ActiveRecord#validates_shape_of` to handle validations
- `ActiveController#permit_shape_params` to handle strong parameters
- `katachi-ts` for `TypeScript` type generation
- `katachi-zod` for `Zod` schema generation
- `katachi-openapi` for `OpenAPI` schema generation & testing
