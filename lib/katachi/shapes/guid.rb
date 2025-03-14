# frozen_string_literal: true

# A shape class for validating GUIDs
class Katachi::Shapes::Guid < Katachi::Shapes::Base
  self.key = :$guid

  def self.shape = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/
end
