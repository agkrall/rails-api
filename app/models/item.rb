class Item < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true

  def object_attributes
    ObjectAttribute.where(object_id: id)
  end

  def self.find_by_upc(upc)
    sql = "SELECT i.* FROM items i, object_attributes oa, attributes a WHERE a.name = '#{Attribute::NAME_UPC}' AND oa.attribute_id = a.id AND oa.object_id = i.id AND oa.value = '#{upc}'"
    Item.find_by_sql(sql).first
  end
end
