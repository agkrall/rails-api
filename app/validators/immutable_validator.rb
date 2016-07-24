class ImmutableValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.persisted? && record.changed.include?(attribute.to_s)
      record.errors[attribute] << (options[:message] || "can't be modified")
    end
  end
end