# frozen_string_literal: true

# CONCEPT IDEA ONLY

# AnyOf is used for allowing multiple shapes to be matched a single value.
# If any of the shapes match the value, the value is considered valid.
# If none of the shapes match the value, the value is considered invalid.
# AnyOf is used in the following way:
# Katachi::Validator.validate(value, Katachi::AnyOf[shape1, shape2, shape3])
class Katachi::AnyOf
  def [](*shapes)
    # To be implemented
  end
end
