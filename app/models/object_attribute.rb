class ObjectAttribute < ApplicationRecord
  belongs_to :associated_attribute , foreign_key: 'attribute_id', class_name: Attribute
  validates :associated_attribute, :object_id, :value, :effective_date, presence: true
end
