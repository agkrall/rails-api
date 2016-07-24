class CreateLocation
  attr_reader :location
  attr_reader :errors

  def initialize(external_id)
    @external_id = external_id
  end

  def run
    location = Location.create(external_id: @external_id)

    if location.errors.empty?
      @location = location.reload      
    else
      @errors = location.errors.to_h
      false
    end
  end
end
