# frozen_string_literal: true

require "debug"

# A data structure for handling composite shapes along with primitive values
class Katachi::ShapeTree
  attr_reader(
    :can_be_boolean,
    :can_be_null,
    :can_be_undefined,
    :categorized,
    :shapeables
  )

  def initialize(*shapeables)
    @shapeables = shapeables
    @can_be_boolean = !shapeables.delete(:boolean).nil?
    @can_be_null = !shapeables.delete(:null).nil?
    @can_be_undefined = !shapeables.delete(:undefined).nil?
    @categorized = shapeables.uniq.compact.group_by do |shapeable|
      case shapeable
      when Symbol then :shape_keys
      when /^\$\w*:.*$/ then :directives
      # when Array then TODO
      # when Object then TODO
      # when Range then TODO
      # when RegExp then TODO
      when String then :strings
      when Numeric then :numbers
      end
    end
  end
end
