class Attribute < ApplicationRecord
  NAME_UPC = 'upc'
  validates :name, presence: true, uniqueness: true
  validates :attribute_type, presence: true, inclusion: {in: %w(string number date boolean),
                                                         message: I18n.t('errors.messages.value_is_not_valid')}
end
