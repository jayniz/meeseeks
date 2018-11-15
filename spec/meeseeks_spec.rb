# frozen_string_literal: true

RSpec.describe Meeseeks do

  let(:instance) do
    instance = instance_double(Meeseeks::Meeseeks)
    allow(instance).to receive(:implode!)
    instance
  end

  after(:each) { Meeseeks.implode! }

  it 'has a version number' do
    expect(Meeseeks::VERSION).not_to be nil
  end

  it 'delegates the record method to the instance' do
    expect(instance).to receive(:record).exactly(5).and_return(:ok)
    expect(Meeseeks::Meeseeks).to receive(:new).once.and_return(instance)

    5.times do
      expect(Meeseeks.record('group', 'metric', 1)).to eq(:ok)
    end
  end

  it 'allows for singleton configuration' do
    Meeseeks.configure(data_submission_url: 'https://foo.bar',
                       interval: 1,
                       max_batch_size: 2,
                       max_queue_size: 3)
    expect(instance).to receive(:record).exactly(5).and_return(:ok)
    expect(Meeseeks::Meeseeks).to receive(:new).with(
      data_submission_url: 'https://foo.bar',
      interval: 1,
      max_batch_size: 2,
      max_queue_size: 3
    ).once.and_return(instance)

    5.times do
      expect(Meeseeks.record('group', 'metric', 1)).to eq(:ok)
    end
  end
end
