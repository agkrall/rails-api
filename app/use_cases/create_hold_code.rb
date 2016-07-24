class CreateHoldCode
  attr_reader :hold_code, :errors

  def initialize(code)
    @code = code
  end

  def run
    hold_code = HoldCode.create(code: @code)

    if hold_code.errors.empty?
      @hold_code = hold_code.reload
    else
      @errors = hold_code.errors.to_h
      false
    end
  end
end