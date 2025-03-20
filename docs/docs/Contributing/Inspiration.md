---
sidebar_position: 4
---

# Inspiration

This project was inspired by my experiences testing using [RSwag](https://github.com/rswag/rswag) and from my small part in helping maintain it. I wasn't happy with how often I had to look up the OpenAPI spec to be able to follow it.

A lot of this came down to OpenAPI itself being complex and making significant changes over the years (e.g. `x-nullable: true` → `nullable: true` → `type: ["string", "null"]`). A bigger part is they're limited to valid JSON, so they have very few tools to work with.

I started wondering if I could tweak RSwag to smooth over some of these rough edges. Is there a way to make it easier to write and harder to mess up?

It started as consolidating a few helper functions together, before a bigger question hit me:

**“What if I ditched writing OpenAPI entirely?”**

Rather than drag all of their maintainers and users along with my crackpot schemes, I decided it was time to set off on a new project: `Katachi`
