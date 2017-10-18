# frozen_string_literal: true

class Workspace < ApplicationRecord
  has_many :views, dependent: :destroy

  def to_s
    name
  end
end
