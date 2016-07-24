class CreateItem
  attr_reader :item
  attr_reader :errors

  def initialize(external_id, attribute_id_value_pairs = nil)
    @external_id = external_id
    @attribute_id_value_pairs = attribute_id_value_pairs
  end

  def run
    item = Item.create(external_id: @external_id)

    if item.errors.empty?
      @item = item
      if @attribute_id_value_pairs
        @attribute_id_value_pairs.each do |attr_pair|
          attribute = Attribute.find_by_id(attr_pair[:attribute_id])
          object_attribute = ObjectAttribute.create(associated_attribute: attribute, object_id: @item.id,
                               value: attr_pair[:value], effective_date: DateTime.now)
          unless object_attribute.errors.empty?
            @errors = object_attribute.errors.to_h
          end
        end
      end
      @errors ? false : @item
    else
      @errors = item.errors.to_h
      false
    end
  end
end
