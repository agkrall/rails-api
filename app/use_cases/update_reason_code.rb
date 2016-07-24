class UpdateReasonCode
  attr_reader :reason_code
  attr_reader :errors

  def initialize(reason_code, description, impacts_soh)
    @description = description
    @reason_code = reason_code
    @impacts_soh = impacts_soh
  end

  def run
    reason_code.update(description: @description, impacts_soh: @impacts_soh)

    if reason_code.errors.empty?
      @reason_code = reason_code
    else
      @errors = reason_code.errors.to_h
      false
    end
  end
end
