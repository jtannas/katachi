# frozen_string_literal: true

require_relative "shapes"

Katachi::Shapes.add(:$uuid, /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
Katachi::Shapes.add(:$guid, /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/)
# TODO: make :$guid reference the :$uuid shape; requires recursive shape resolution
