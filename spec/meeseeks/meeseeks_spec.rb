# frozen_string_literal: true

RSpec.describe Meeseeks do
  let(:interval) { 0.1 }
  let(:meeseeks) do
    m = Meeseeks::Meeseeks.new(
      data_submission_url: 'http://localhost:2202',
      interval: interval,
      max_batch_size: 10
    )

    val = 0
    30.times { m.record('test', 'foo', (val += 1), Date.parse('2013-02-22')) }

    m
  end

  after(:each) do
    meeseeks.implode!
  end

  context 'configuration' do
    it 'has messages in the queue' do
      expect(meeseeks.queue.size).to eq(30)
    end

    it 'purges every second' do
      expect(meeseeks.harvester.interval).to eq(interval)
    end
  end

  context 'submitting' do
    it 'successfully' do
      expect(meeseeks.http_trap).to receive(:submit)
        .at_least(4).at_most(5).times
        .with(any_args)
      meeseeks
      sleep interval * 1.5
    end

    it 'resubmit on error' do
      expect(meeseeks.http_trap).to receive(:submit)
        .twice.and_raise('no no no')
      expect(meeseeks.http_trap).to receive(:submit)
        .at_least(4).at_most(5).times
        .with(any_args)
      meeseeks
      sleep interval * 1.5
    end
  end

  context 'reporting' do
    it 'returning false on error' do
      expect(meeseeks).to receive(:record!).and_raise(Meeseeks::Error.new)
      expect(meeseeks.record('test', 'metric', 1)).to be_falsy
    end

    it 'stats' do
      expect(meeseeks.stats).to eq(queue_size: 30,
                                   imploded: false,
                                   harvester: {
                                     cycle_count: 0,
                                     running: true
                                   },
                                   http_trap: {
                                     submit_count: 0,
                                     last_submit_at: nil
                                   })
    end
  end

  context '#time' do
    it 'calls record' do
      expect(meeseeks).to receive(:record!).with('test', 'foo', instance_of(DateTime))
      meeseeks.time('test', 'foo') { 1 + 1 }
    end

    it 'records an error if the block raises an error' do
      expect(meeseeks).to receive(:record!).with('test', 'foo-error', instance_of(DateTime))
      meeseeks.time('test', 'foo') { raise 'boom' }
    end
  end

  context 'max queue size' do
    it 'limits the queue size' do
      m = Meeseeks::Meeseeks.new(
        data_submission_url: 'http://localhost:2202',
        interval: 1000,
        max_batch_size: 10,
        max_queue_size: 2
      )
      expect(m.record('foo', 'bar', 1)).to be_truthy
      expect(m.record('foo', 'bar', 1)).to be_truthy
      expect(m.record('foo', 'bar', 1)).to be_falsy
    end
  end
end
