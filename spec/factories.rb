FactoryGirl.define do
  factory :attribute do
    name { "unit test name #{SecureRandom.uuid}" }
    attribute_type { 'string' }
  end
  factory :item do
    external_id { "test external id #{SecureRandom.uuid}" }
  end
  factory :inventory_adjustment do
    external_transaction_id { "test external id #{SecureRandom.uuid}" }
    item { create :item }
    location { create :location }
    quantity { 4.2 }
    uom_code { 'EA' }
    transaction_code { 'InventoryAdjustment' }
  end
  factory :inventory_count do
    external_transaction_id { "test external id #{SecureRandom.uuid}" }
    item_id { SecureRandom.uuid }
    location_id { SecureRandom.uuid }
    quantity { 4.2 }
    uom_code { 'EA' }
    transaction_code { 'InventoryCount' }
  end
  factory :location do
    external_id { "test external id #{SecureRandom.uuid}" }
  end
  factory :object_attribute do
    associated_attribute { create :attribute }
    effective_date { DateTime.now }
    value { '43' }
  end
  factory :reason_code do
    sequence(:code, 100) { |n| "REASON#{n}" }
    sequence(:description, 100) { |n| "Description for REASON#{n}" }
    impacts_soh { true }
  end
  factory :user do
    sequence(:username, 100) { |n| "admin#{n}" }
    password { 'password' }
  end
  factory :hold_code do
    sequence(:code, 100) { |n| "HOLD#{n}" }
  end
end
