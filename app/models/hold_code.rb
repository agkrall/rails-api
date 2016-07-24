class HoldCode < ApplicationRecord
  has_and_belongs_to_many :inventory_holds
  validates :code, presence: true, uniqueness: true, immutable: true

  def attributes
    {:code => nil}
  end
end