# frozen_string_literal: true
class Category < ApplicationRecord
  has_many :layers, dependent: :nullify
  def pretty_name
    postfix.blank? ? name : "#{name} - #{postfix.try(:truncate, 50)}"
  end
end
