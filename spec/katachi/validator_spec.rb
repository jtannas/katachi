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
        { value: "c", shapes: ["c"..."x"] } => true,
        { value: "c", shapes: ["d"..."x"] } => false,
        { value: "c", shapes: [1...3] } => false,
      }
    )
  end

  describe ".valid_number?" do
    it_behaves_like(
      "a pure kwargs function",
      method: :valid_number?,
      kwargs_to_outputs: {
        { value: 1, shapes: [1] } => true,
        { value: 1, shapes: [1...2] } => true,
        { value: 1, shapes: [:foo] } => false,
        { value: 1, shapes: ["$foo:bar"] } => false,
        { value: 1, shapes: [1...4] } => true,
        { value: 1, shapes: [4...7] } => false,
        { value: 1, shapes: ["a"..."d"] } => false,
      }
    )
  end

  describe ".valid_boolean?" do
    it_behaves_like(
      "a pure kwargs function",
      method: :valid_boolean?,
      kwargs_to_outputs: {
        { value: true, shapes: [:boolean] } => true,
        { value: true, shapes: [true] } => true,
        { value: false, shapes: [false] } => true,
        { value: true, shapes: [false] } => false,
        { value: false, shapes: [true] } => false,
        { value: true, shapes: [1] } => false,
        { value: true, shapes: [:foo] } => false,
        { value: true, shapes: ["$foo:bar"] } => false,
      }
    )
  end

  describe ".valid_null?" do
    it_behaves_like(
      "a pure kwargs function",
      method: :valid_null?,
      kwargs_to_outputs: {
        { shapes: [:boolean] } => false,
        { shapes: [nil] } => true,
        { shapes: [] } => false,
      }
    )
  end
end
