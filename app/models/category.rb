class Category < ApplicationRecord
  has_many :layers, dependent: :nullify
  def pretty_name
    "#{name} - #{postfix.truncate(50)}"
  end
end
