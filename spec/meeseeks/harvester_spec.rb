# frozen_string_literal: true

RSpec.describe Meeseeks do
  let(:interval) { 0.1 }
  let(:trap) { Meeseeks::HTTPTrap.new('http://localhost:2202') }
  let(:harvester) do
    h = Meeseeks::Harvester.new(
      queue: Queue.new,
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
