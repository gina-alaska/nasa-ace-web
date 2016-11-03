# frozen_string_literal: true
class ViewLayer < ApplicationRecord
  belongs_to :view
  belongs_to :layer
  acts_as_list scope: :view

  validates :layer_id, uniqueness: { scope: :view_id }
end
