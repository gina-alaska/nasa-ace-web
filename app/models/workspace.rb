# frozen_string_literal: true
class Workspace < ApplicationRecord
  has_many :views

  def to_s
    name
  end
end
