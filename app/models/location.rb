class Location < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true
end
