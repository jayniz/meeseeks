# frozen_string_literal: true

RSpec.describe Meeseeks do
  it 'has a version number' do
    expect(Meeseeks::VERSION).not_to be nil
  end

  it 'delegates the record method to the instance' do
    instance = double(Meeseeks::Meeseeks)
    expect(instance).to receive(:record).and_return(:ok)
    expect(Meeseeks::Meeseeks).to receive(:new).once.and_return(instance)
    expect(Meeseeks.record).to eq(:ok)
  end
end
