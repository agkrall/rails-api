class UpdateLocation
  attr_reader :location
  attr_reader :errors

  def initialize(location, external_id)
    @external_id = external_id
    @location = location
  end

  def run
    location.update(external_id: @external_id)

    if location.errors.empty?
      @location = location
    else
      @errors = location.errors.to_h
      false
    end
  end
end
