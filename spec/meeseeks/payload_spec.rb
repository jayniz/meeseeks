# frozen_string_literal: true

RSpec.describe Meeseeks::Payload do
  subject { Meeseeks::Payload }

  it 'does not allow invalid types' do
    expect do
      subject.validate_type!(an: :object)
    end.to raise_error(Meeseeks::Errors::InvalidType)
  end

  it 'produces the expected payload' do
    p = {
      'metric' => {
        '_ts'    => 1_350_912_633_000_000,
        '_type'  => 'n',
        '_value' => 22.02
      }
    }
    expect(subject.for('metric', 22.02, Time.at(1_350_912_633_000))).to eq(p)
  end
end
