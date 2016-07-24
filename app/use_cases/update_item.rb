class UpdateItem
  attr_reader :item
  attr_reader :errors

  def initialize(item, external_id)
    @external_id = external_id
    @item = item
  end

  def run
    item.update(external_id: @external_id)

    if item.errors.empty?
      @item = item
    else
      @errors = item.errors.to_h
      false
    end
  end
end
