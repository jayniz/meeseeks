# frozen_string_literal: true

RSpec.describe Meeseeks::HTTPTrap do
  let(:http_trap) { Meeseeks::HTTPTrap.new('http://localhost/foo') }

  it 'puts the payload on its request or else it gets the hose again' do
    req = double(Net::HTTP::Put)
    expect(req).to receive(:body=).with("\"foobar\"\n\"barfoo\"")

    expect(Net::HTTP::Put).to receive(:new)
      .with('/foo', 'Content-Type' => 'application/json')
      .and_return(req)

    response = double
    expect(response).to receive(:body).and_return('{"ok": true}')

    http = double(Net::HTTP)
    expect(http).to receive(:use_ssl=).with(false)
    expect(http).to receive(:request).with(req).and_return(response)
    expect(Net::HTTP).to receive(:new).with('localhost', 80).and_return(http)

    expect(http_trap.submit(%w[foobar barfoo])).to eq('ok' => true)
  end
end
