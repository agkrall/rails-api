shared_examples 'a newly created model instance' do
  it 'creates timestamp values' do
    expect(subject.created_at).to be_within(1.second).of(Time.now)
    expect(subject.updated_at).to be_within(1.second).of(Time.now)
  end
end

shared_examples 'an instance with a validation error' do |expected_failed_attribute, expected_message_key, interpolation_args = nil|
  it 'internationalizes the message' do
    message = I18n.t(expected_message_key, interpolation_args)
    subject.validate
    expect(subject.errors.first).to eq [expected_failed_attribute, message]
  end
end
