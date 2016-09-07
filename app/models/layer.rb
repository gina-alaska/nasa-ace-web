class Layer < ApplicationRecord
  belongs_to :category

  validates :name, presence: true
  validates :url, presence: true

  def full_url
    File.join(url, category.postfix)
  end
end
