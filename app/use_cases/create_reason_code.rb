class CreateReasonCode
  attr_reader :reason_code, :errors

  def initialize(code, description, impacts_soh)
    @code = code
    @description = description
    @impacts_soh = impacts_soh
  end

  def run
    reason_code = ReasonCode.create(code: @code, description: @description, impacts_soh: @impacts_soh)

    if reason_code.errors.empty?
      @reason_code = reason_code.reload
    else
      @errors = reason_code.errors.to_h
      false
    end
  end
end
