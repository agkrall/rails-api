class CreateAttribute
  attr_reader :attribute
  attr_reader :errors

  def initialize(name, attribute_type)
    @name = name
    @attribute_type = attribute_type
  end

  def run
    attribute = Attribute.create(name: @name, attribute_type: @attribute_type)

    if attribute.errors.empty?
      @attribute = attribute.reload      
    else
      @errors = attribute.errors.to_h
      false
    end
  end
end
