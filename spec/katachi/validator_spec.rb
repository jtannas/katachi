# frozen_string_literal: true

RSpec.describe Katachi::Validator do
  describe ".valid_string?" do
    it_behaves_like(
      "a pure kwargs function",
      method: :valid_string?,
      kwargs_to_outputs: {
        { value: "foo", shapes: ["foo"] } => true,
        { value: "foo", shapes: [/foo/] } => true,
        { value: "foo", shapes: [:foo] } => false,
        { value: "foo", shapes: ["$foo:bar"] } => false,
        { value: "foo", shapes: ["$foo:bar"] } => false,
      }
    )
  end
end
