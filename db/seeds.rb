# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

upc_attr = Attribute.create!(name: Attribute::NAME_UPC, attribute_type: 'string')

(1..25).each do |i|
  item = Item.create external_id: "test external id #{i}"
  puts "Created new Item with id #{item.id} and external id #{item.external_id}"
  fake_upc = "UPC#{i}"
  ObjectAttribute.create!(associated_attribute: upc_attr,
                          object_id: item.id,
                          value: fake_upc,
                          effective_date: Time.now)
  puts "...and UPC '#{fake_upc}'"
  location = Location.create external_id: "test external id #{i}"
  puts "Created new Location with id #{location.id} and external id #{location.external_id}"
end

[{code: '1', description: 'Software correction of inventory discrepancies', impacts_soh: true},
{code: '3', description: 'Product redefinition and transfer in from original inventory item', impacts_soh: true},
{code: '4', description: 'Product redefinition and transfer out to new inventory item', impacts_soh: false},
{code: '5', description: 'Unrecoverable inventory', impacts_soh: false},
{code: '6', description: 'Damaged by inbound carrier', impacts_soh: true},
{code: 'D', description: 'Destroyed', impacts_soh: true},
{code: 'E', description: 'Damaged at Amazon fulfillment center', impacts_soh: false},
{code: 'F', description: 'Inventory found', impacts_soh: true},
{code: 'H', description: 'Damaged – customer return', impacts_soh: false},
{code: 'J', description: 'Software correction of inventory discrepancies', impacts_soh: false},
{code: 'K', description: 'Damaged as result of item defect', impacts_soh: false},
{code: 'M', description: 'Inventory misplaced', impacts_soh: true},
{code: 'N', description: 'Transfer from holding account', impacts_soh: true},
{code: 'O', description: 'Transfer to holding account', impacts_soh: false},
{code: 'P', description: 'Unsellable inventory', impacts_soh: true},
{code: 'Q', description: 'Damaged – miscellaneous', impacts_soh: true},
{code: 'U', description: 'Damaged by merchant', impacts_soh: false}].each {|params| ReasonCode.create(params)}

User.create(username: 'admin', password: 'admin')
