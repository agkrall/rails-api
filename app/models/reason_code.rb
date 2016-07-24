class ReasonCode < ApplicationRecord
  validates :code, presence: true, uniqueness: true, length: {maximum: 22}, immutable: true
  validates :description, presence: true
  validates :impacts_soh, :inclusion => {:in => [true, false]}

  def attributes
    {:code => nil, :description => nil, :impacts_soh => nil}
  end
end
