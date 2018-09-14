# frozen_string_literal: true

RSpec.describe Meeseeks::Payload do
  it 'does not allow invalid types' do
    expect do
      Meeseeks::Payload.validate_type!(an: :object)
    end.to raise_error(Meeseeks::Errors::InvalidType)
  end
end
