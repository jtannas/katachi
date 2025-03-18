# frozen_string_literal: true

require_relative "compare_kv"

# Katachi::Comparator.compare_hash is the main entry point for comparing hashes.
# It is called by Katachi::Comparator.compare and should not be called directly.
# It returns a Katachi::ComparisonResult object.
#
# WARNING: HERE BE DRAGONS
# The methods in this section of the module are gnarly and heavily recursive.
# For the story of why it was built this way, see `docs/HASH_COMPARISON_DESIGN.md`.
module Katachi::Comparator
  # Compare a value that is a hash against a shape
  # This method is called by Katachi::Comparator.compare and should not be called directly.
  # It is not private so that it can be tested directly.
  #
  # @param value [Hash] the value to compare
  # @param shape [Object] the shape to compare against
  # @return [Katachi::ComparisonResult] the result of the comparison
  def self.compare_hash(value:, shape:)
    failure = precompare_hash(value:, shape:)
    return failure if failure

    child_results = {
      "$required_keys": compare_hash_required_keys(value_keys: value.keys, shape:),
      "$extra_keys": compare_hash_extra_keys(value_keys: value.keys, shape_keys: shape.keys),
      "$values": compare_hash_values(value:, shape:),
    }
    # All categories of checks must pass for the hash to be a match
    code = child_results.values.all?(&:match?) ? :hash_is_match : :hash_is_mismatch
    Katachi::ComparisonResult.new(value:, shape:, code:, child_results:)
  end

  # Check for early exit conditions that don't require iterating over the hash
  #
  # @param value [Hash] the value to compare
  # @param shape [Object] the shape to compare against
  # @return [Katachi::ComparisonResult, nil] the result of the comparison, or nil if no early exit condition is met
  private_class_method def self.precompare_hash(value:, shape:)
    raise ArgumentError, "checked value must be a hash" unless value.is_a?(Hash)

    early_exit_code = if shape == Hash then :hash_class_matches_any_hash
                      elsif !shape.is_a?(Hash) then :class_mismatch
                      elsif value == shape then :hash_is_exact_match
                      else
                        return
                      end

    Katachi::ComparisonResult.new(value:, shape:, code: early_exit_code)
  end

  # Examines the keys of the shape to determine if any are required
  # and then checks that the value has all required keys.
  # It takes the full shape as an argument rather than just the keys
  # because `:$undefined` in the `value` portion of a key-value pair
  # affects whether a key is allowed to be omitted.
  #
  # @param value_keys [Array] the keys of the value
  # @param shape [Hash] the shape to compare against
  # @return [Katachi::ComparisonResult] the result of the comparison
  private_class_method def self.compare_hash_required_keys(value_keys:, shape:)
    checks = shape.keys.filter_map do |k|
      check_key_requirement_status(value_keys:, shape:, shape_key: k) if required_key?(k)
    end
    Katachi::ComparisonResult.new(
      value: value_keys,
      shape:,
      code: checks.all?(&:match?) ? :hash_has_no_missing_keys : :hash_has_missing_keys,
      child_results: checks.to_h { |check| [check.shape, check] },
    )
  end

  # Check if a key is present, optional, or missing
  #
  # @param value_keys [Array] the keys of the value
  # @param shape [Hash] the shape to compare against
  # @param shape_key [Object] the key from the shape to check the value_keys for
  # @return [Katachi::ComparisonResult] the result of the comparison
  private_class_method def self.check_key_requirement_status(value_keys:, shape:, shape_key:)
    shared = {
      shape: shape_key,
      child_results: value_keys.to_h { |v_key| [v_key, compare(value: v_key, shape: shape_key)] },
    }
    if value_keys.include?(shape_key)
      Katachi::ComparisonResult.new(value: shape_key, code: :hash_key_exact_match, **shared)
    elsif shared[:child_results].values.any?(&:match?)
      Katachi::ComparisonResult.new(value: value_keys, code: :hash_key_match, **shared)
    elsif optional_key?(shape[shape_key])
      Katachi::ComparisonResult.new(value: :$undefined, code: :hash_key_optional, **shared)
    else
      Katachi::ComparisonResult.new(value: :$undefined, code: :hash_key_missing, **shared)
    end
  end

  # Determine if a key is required
  # A key is not considered to be required if it implements a case
  # equality operator (`===`) for loosely matching values.
  # This is typically used for matching classes, ranges, regexes, etc.
  # Arrays, hashes, and AnyOf are considered required if all of contents are required
  #
  # @param key [Object] a key in the shape that we want to know if it fits the criteria for being required
  # @return [Boolean] true if the key is required, false
  private_class_method def self.required_key?(key) # rubocop:disable Metrics/CyclomaticComplexity
    case key
    when Array, Katachi::AnyOf then key.all? { |k| required_key?(k) }
    when Hash then key.all? { |(k, v)| required_key?(k) && required_key?(v) }
    when ->(k) { Katachi::Shapes.valid_key?(k) } then required_key?(Katachi::Shapes[key])
    when ->(k) { k.method(:===) != k.method(:==) } then false
    else true
    end
  end

  # Determine if a key is optional via the presence of the `$undefined` shape
  # It uses `compare` instead of `.include?` because the shape may be a reference
  # to a shape like `:$optional_string --> Katachi::AnyOf[String, :$undefined]`.
  #
  # @param shape_value [Object] the "value" portion of a key-value pair in the shape
  # @return [Boolean] true if the key is optional, false otherwise
  private_class_method def self.optional_key?(shape_value) = compare(value: :$undefined, shape: shape_value).match?

  # Compare the keys of the value against the keys of the shape.
  #
  # @param value_keys [Array] the keys of the value
  # @param shape_keys [Array] the keys of the shape
  # @return [Katachi::ComparisonResult] the result of the comparison
  private_class_method def self.compare_hash_extra_keys(value_keys:, shape_keys:)
    checks = value_keys.map { |key| check_extra_key_status(shape_keys:, value_key: key) }
    Katachi::ComparisonResult.new(
      value: value_keys,
      shape: shape_keys,
      code: checks.all?(&:match?) ? :hash_has_no_extra_keys : :hash_has_extra_keys,
      child_results: checks.to_h { |check| [check.value, check] },
    )
  end

  # Check if a key is exactly equal (==) to a key in the shape
  # or if it matches via our usual `compare` method.
  #
  # @param shape_keys [Array] the keys of the shape
  # @param value_key [Object] the key to check if it matches any of the shape keys
  # @return [Katachi::ComparisonResult] the result of the comparison
  private_class_method def self.check_extra_key_status(shape_keys:, value_key:)
    key_results = shape_keys.to_h { |s_key| [s_key, compare(value: value_key, shape: s_key)] }
    code = if shape_keys.include?(value_key) then :hash_key_exactly_allowed
           elsif key_results.values.any?(&:match?) then :hash_key_match_allowed
           else
             :hash_key_not_allowed
           end
    Katachi::ComparisonResult.new(value: value_key, shape: shape_keys, code:, child_results: key_results)
  end

  # Compare the values of the hash against the values of the shape.
  # In the case where the exact same key is present in both the value and the shape,
  # then it gets sent to be compared by `compare_specific_kv`.
  # Otherwise, it gets sent to be compared by `compare_general_kv`.
  # This is to support when users want to match a subset of the keys in a hash.
  # e.g. `compare(value: User.last, shape: { email: request.params[:email], Symbol => Object })`
  #
  # @param value [Hash] the value to compare
  # @param shape [Hash] the hash shape to compare against
  # @return [Katachi::ComparisonResult] the result of the comparison
  private_class_method def self.compare_hash_values(value:, shape:)
    individual_checks = value.keys.to_h do |v_key|
      value_kv = value.slice(v_key)
      [value_kv, shape.key?(v_key) ? compare_specific_kv(value_kv:, shape:) : compare_general_kv(value_kv:, shape:)]
    end
    Katachi::ComparisonResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_values_are_match : :hash_values_are_mismatch,
      child_results: individual_checks,
    )
  end
end
