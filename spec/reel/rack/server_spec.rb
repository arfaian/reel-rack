require 'spec_helper'
require 'net/http'
require 'rack/lint'
require 'rack/head'

describe Reel::Rack::Server do
  let(:host) { "127.0.0.1" }
  let(:port) { 30000 }
  let(:headers) { {"Content-Type" => "text/plain", "Content-Length" => body.length.to_s} }
  let(:body) { "hello world" }
  let(:uri) { URI("http://#{host}:#{port}/") }
  let(:http) { Net::HTTP.new(uri.host, uri.port) }

  subject do
    app = proc { [200, headers, [body]] }
    described_class.new(Rack::Lint.new(Rack::Head.new(app)), :Host => host, :Port => port)
  end

  before do
    # Hax to wait for server to be started
    subject.inspect
  end

  after do
    subject.terminate
  end


  it "runs a basic Hello World app" do
    expect(http.request_get(uri.path).body).to eq body
  end

  it "success with basic HTTP methods" do
    expect(http.request_get(uri.path).body).to eq body
    expect(http.request_head(uri.path).body).to eq nil

    expect(http.send_request('POST', uri.path, "test").body).to eq body
    expect(http.send_request('PUT', uri.path, "test").body).to eq body
    expect(http.send_request('PATCH', uri.path, "test").body).to eq body
    expect(http.send_request('DELETE', uri.path).body).to eq body

  end
end
