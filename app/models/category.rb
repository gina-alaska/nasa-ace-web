class Category < ApplicationRecord
  def pretty_name
    "#{name} - #{postfix.truncate(50)}"
  end
end
