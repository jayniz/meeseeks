# frozen_string_literal: true

RSpec.describe Meeseeks do
  let(:interval) { 0.1 }
  let(:trap) { Meeseeks::HTTPTrap.new('http://localhost:2202') }
  let(:queue) { Queue.new }
  let(:harvester) do
    h = Meeseeks::Harvester.new(
      queue: queue,
      http_trap: trap,
      interval: interval,
      max_batch_size: 10
    )
    h.start
    h
  end

  after(:each) do
    harvester.kill
  end

  it 'does not die if a queue is unexpectedly empty' do
    allow(queue).to receive(:empty?).and_return false
    expect { harvester.send(:batch_from_queue) }.to_not raise_error
  end

  it 'allows killing the thread' do
    expect do
      harvester.kill
      sleep interval
    end.to change { harvester.running? }.from(true).to(false)
  end

  it 'allows stopping the thread' do
    expect do
      harvester.stop
      sleep 2 * interval
    end.to change { harvester.running? }.from(true).to(false)
  end
end
