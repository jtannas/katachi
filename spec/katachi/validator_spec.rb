# frozen_string_literal: true

RSpec.describe Katachi::Validator do
  describe ".valid?" do
    it_behaves_like(
      "a pure kwargs function",
      method: :valid?,
      kwargs_to_outputs: {
        # String
        { value: "foo", shapes: ["foo"] } => true,
        { value: "foo", shapes: [/foo/] } => true,
        { value: "foo", shapes: [:foo] } => false,
        { value: "foo", shapes: ["$foo:bar"] } => false,
        { value: "c", shapes: ["c"..."x"] } => true,
        { value: "c", shapes: ["d"..."x"] } => false,
        { value: "c", shapes: [1...3] } => false,
        # Numbers
        { value: 1, shapes: [1] } => true,
        { value: 1, shapes: [1...2] } => true,
        { value: 1, shapes: [:foo] } => false,
        { value: 1, shapes: ["$foo:bar"] } => false,
        { value: 1, shapes: [1...4] } => true,
        { value: 1, shapes: [4...7] } => false,
        { value: 1, shapes: ["a"..."d"] } => false,
        # Booleans
        { value: true, shapes: [true] } => true,
        { value: false, shapes: [false] } => true,
        { value: true, shapes: [false] } => false,
        { value: false, shapes: [true] } => false,
        { value: true, shapes: [1] } => false,
        { value: true, shapes: [:foo] } => false,
        { value: true, shapes: ["$foo:bar"] } => false,
        # Nil
        { value: nil, shapes: [nil] } => true,
        { value: nil, shapes: [1] } => false,
        { value: nil, shapes: [] } => false,
        # Simple Arrays
        { value: [], shapes: [[]] } => true,
        { value: [], shapes: [[Integer]] } => true,
        { value: [1], shapes: [[Integer]] } => true,
        { value: [1, 2, 3], shapes: [[Integer]] } => true,
        { value: [1, 2, 3, "a"], shapes: [[Integer]] } => false,
        { value: [1, "a"], shapes: [[Integer, String]] } => true,
        { value: [nil], shapes: [[Integer, nil]] } => true,
        # Nested Arrays
        { value: [[nil]], shapes: [[Integer, nil]] } => false,
        { value: [[nil]], shapes: [[[nil]]] } => true,
        { value: [1, 2, ["a"]], shapes: [[Integer, [String]]] } => true,
        { value: [
            %w[First Last Age],
            ["John", "Doe", 42],
            ["Jane", "Doris", 59]
          ],
          shapes: [[[String, Integer]]] } => true,
      }
    )
  end
end
