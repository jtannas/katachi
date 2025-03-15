# Philosophy

> Every well-established project should have a philosophy that guides its development.
> Without a core philosophy, development can languish in endless decision-making and have weaker APIs as a result.
> https://tanstack.com/form/latest/docs/philosophy

## Be Intuitive

- When defining shapes for comparison, we want users to be able to guess the correct action.
  > "I want this to be a string" -> use `String`
  > "I want this text to follow look like "foo" -> use `/foo/`
- If the user has to reference our docs more than once, we should aim for better.

## Be Minimal

- The smaller the public API, the faster users can pick it up and be productive.
- Rely on existing Ruby (eg. `===`, `in`, procs, etc...) so people can use the tool at the skill level they're comfortable.

## Be Predictable

- Minimal state. At the time of writing this the only mutable state in the entire project is the shape library.
- No hidden side effects. Nothing should be altered unless the user explicitly asks for it.

## Be Reliable

- Extensively test all code
- Eliminate dependencies whenever possible so we're less vulnerable to outside influences.

## Be Ruthless To Systems. Be Kind To People.

- ^ quote from Michael Brooks

People -- whether users or contributors -- are going to make mistakes.
We should be understanding and forgiving when they do.

That being said, if we let something slip then every user has to deal with it.
We should be meticulous in our code to avoid giving users a bad experience.

To that end, we lean heavily on automated dev tooling to keep everything on track.
Linters, formatters, spellcheckers, scanners -- we'll use it all.
