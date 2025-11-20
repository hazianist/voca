class Tag < ApplicationRecord
  HEAVY_USAGE_THRESHOLD = 5

  has_many :taggings
  has_many :words, through: :taggings

  has_and_belongs_to_many :words, dependent: :destroy
  belongs_to :user

  validates :name, presence: true

  def usage_count
    self[:usage_count] || self[:taggings_count] || taggings.size
  end
end
