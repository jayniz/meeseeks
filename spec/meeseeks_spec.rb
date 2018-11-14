# frozen_string_literal: true

RSpec.describe Meeseeks do
  after(:each) do
    Meeseeks.instance_variable_set(:@instance, false)
  end

  it 'has a version number' do
    expect(Meeseeks::VERSION).not_to be nil
  end

  it 'delegates the record method to the instance' do
    instance = double(Meeseeks::Meeseeks)
    expect(instance).to receive(:record).twice.and_return(:ok)
    expect(Meeseeks::Meeseeks).to receive(:new).once.and_return(instance)
    expect(Meeseeks.record).to eq(:ok)
    expect(Meeseeks.record).to eq(:ok)
  end

  it 'allows for singleton configuration' do
    Meeseeks.configure(data_submission_url: 'https://foo.bar',
                       interval: 1,
                       max_batch_size: 2,
                       max_queue_size: 3)
    instance = double(Meeseeks::Meeseeks)
    expect(instance).to receive(:record).twice.and_return(:ok)
    expect(Meeseeks::Meeseeks).to receive(:new).with(
      data_submission_url: 'https://foo.bar',
      interval: 1,
      max_batch_size: 2,
      max_queue_size: 3
    ).once.and_return(instance)
    expect(Meeseeks.record).to eq(:ok)
    expect(Meeseeks.record).to eq(:ok)
  end
end
