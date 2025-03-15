# frozen_string_literal: true

require_relative "shapes"

Katachi::Shapes.add(:$uuid, /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
