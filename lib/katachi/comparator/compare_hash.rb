# frozen_string_literal: true

# Checks a hash against a given shape; returns a Katachi::Result
module Katachi::Comparator
  def self.compare_hash(value:, shape:)
    failure = precompare_hash(value:, shape:)
    return failure if failure

    child_results = {
      "$required_keys": compare_hash_required_keys(value:, shape:),
      "$extra_keys": compare_hash_extra_keys(value:, shape:),
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

  private_class_method def self.compare_hash_required_keys(value:, shape:)
    individual_checks = shape.keys.each_with_object({}) do |s_key, results|
      next unless is_required_key?(s_key)

      result_kwargs = { value: s_key, shape: s_key, code: :hash_key_exact_match } if value.key?(s_key)

      result_kwargs ||= begin
        child_results = value.keys.each_with_object({}) do |v_key, cr|
          cr[v_key] = compare(value: v_key, shape: s_key)
        end
        matched_values = child_results.values.select(&:match?)
        if matched_values.any?
          {
            value: matched_values.map(&:value),
            shape: s_key,
            code: :hash_key_match,
            child_results:,
          }
        end
      end

      if compare(value: :$undefined, shape: shape[s_key]).match?
        result_kwargs ||= { value: s_key, shape: s_key, code: :hash_key_optional }
      end

      result_kwargs ||= { value: s_key, shape: s_key, code: :hash_key_missing }
      results[s_key] = Katachi::ComparisonResult.new(**result_kwargs)
    end
    Katachi::ComparisonResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_has_no_missing_keys : :hash_has_missing_keys,
      child_results: individual_checks,
    )
  end

  private_class_method def self.is_required_key?(key)
    case key
    when Class, Regexp, Range, Proc then false
    when Array then key.all? { |k| is_required_key?(k) }
    when Hash then key.all? { |(k, v)| is_required_key?(k) && is_required_key?(v) }
    when ->(k) { Katachi::Shapes.valid_key?(k) } then is_required_key?(Katachi::Shapes[key])
    else true
    end
  end

  private_class_method def self.compare_hash_extra_keys(value:, shape:)
    individual_checks = value.keys.each_with_object({}) do |key, results|
      if shape.key?(key)
        results[key] = Katachi::ComparisonResult.new(
          value: key,
          shape: key,
          code: :hash_key_exactly_allowed,
        )
        next
      end
      key_results = shape.keys.each_with_object({}) do |shape_key, kr|
        kr[shape_key] = compare(value: key, shape: shape_key)
      end
      results[key] = Katachi::ComparisonResult.new(
        value: key,
        shape: shape.keys,
        code: key_results.values.any?(&:match?) ? :hash_key_match_allowed : :hash_key_not_allowed,
        child_results: key_results,
      )
    end
    Katachi::ComparisonResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_has_no_extra_keys : :hash_has_extra_keys,
      child_results: individual_checks,
    )
  end

  private_class_method def self.compare_hash_values(value:, shape:)
    individual_checks = value.each_with_object({}) do |value_kv, results|
      results[Hash[*value_kv]] = if shape.key?(value_kv[0])
                                   compare_specific_kv(value_kv:, shape:)
                                 else
                                   compare_general_kv(value_kv:, shape:)
                                 end
    end
    Katachi::ComparisonResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_values_are_match : :hash_values_are_mismatch,
      child_results: individual_checks,
    )
  end

  private_class_method def self.compare_specific_kv(value_kv:, shape:)
    checked_shape = shape[value_kv[0]]
    result = compare(value: value_kv[1], shape: checked_shape)
    Katachi::ComparisonResult.new(
      value: Hash[*value_kv],
      shape: shape.slice(value_kv[0]),
      code: result.match? ? :kv_specific_match : :kv_specific_mismatch,
      child_results: { checked_shape => result },
    )
  end

  private_class_method def self.compare_general_kv(value_kv:, shape:)
    value_kv_results = shape.each_with_object({}) do |shape_kv, kv_results|
      kv_results[Hash[*shape_kv]] = compare_individual_kv(value_kv:, shape_kv:)
    end
    Katachi::ComparisonResult.new(
      value: Hash[*value_kv],
      shape:,
      code: value_kv_results.values.any?(&:match?) ? :kv_match : :kv_mismatch,
      child_results: value_kv_results,
    )
  end

  private_class_method def self.compare_individual_kv(value_kv:, shape_kv:)
    key_result = compare(value: value_kv[0], shape: shape_kv[0])
    value_result = compare(value: value_kv[1], shape: shape_kv[1])
    code = if !key_result.match? then :kv_key_mismatch
           elsif !value_result.match? then :kv_value_mismatch
           else
             :kv_value_match
           end
    Katachi::ComparisonResult.new(
      value: Hash[*value_kv],
      shape: Hash[*shape_kv],
      code:,
      child_results: { "$kv_key": key_result, "$kv_value": value_result },
    )
  end
end
