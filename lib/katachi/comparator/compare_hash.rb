# frozen_string_literal: true

require_relative "compare_kv"

# Checks a hash against a given shape; returns a Katachi::Result
module Katachi::Comparator
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

  private_class_method def self.required_key?(key) # rubocop:disable Metrics/CyclomaticComplexity
    case key
    when Class, Regexp, Range, Proc then false
    when Array then key.all? { |k| required_key?(k) }
    when Hash then key.all? { |(k, v)| required_key?(k) && required_key?(v) }
    when ->(k) { Katachi::Shapes.valid_key?(k) } then required_key?(Katachi::Shapes[key])
    else true
    end
  end

  private_class_method def self.optional_key?(shape_value) = compare(value: :$undefined, shape: shape_value).match?

  private_class_method def self.compare_hash_extra_keys(value_keys:, shape_keys:)
    checks = value_keys.map { |key| check_extra_key_status(shape_keys:, value_key: key) }
    Katachi::ComparisonResult.new(
      value: value_keys,
      shape: shape_keys,
      code: checks.all?(&:match?) ? :hash_has_no_extra_keys : :hash_has_extra_keys,
      child_results: checks.to_h { |check| [check.value, check] },
    )
  end

  private_class_method def self.check_extra_key_status(shape_keys:, value_key:)
    key_results = shape_keys.to_h { |s_key| [s_key, compare(value: value_key, shape: s_key)] }
    code = if shape_keys.include?(value_key) then :hash_key_exactly_allowed
           elsif key_results.values.any?(&:match?) then :hash_key_match_allowed
           else
             :hash_key_not_allowed
           end
    Katachi::ComparisonResult.new(value: value_key, shape: shape_keys, code:, child_results: key_results)
  end

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
