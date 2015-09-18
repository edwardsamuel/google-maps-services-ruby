require 'spec_helper'

describe GoogleMapsService::Client do
  include_context 'HTTP client'

  context '.urlencode' do
    it 'should only encode non-reserved characters' do
      encoded_params = GoogleMapsService::Client.urlencode_params([["address", "=Sydney ~"]])
      expect(encoded_params).to eq("address=%3DSydney+~")
    end
  end

  context '.sign_hmac' do
    it 'signs with HMAC SHA1 signature' do
      # From http://en.wikipedia.org/wiki/Hash-based_message_authentication_code
      #
      # HMAC_SHA1("key", "The quick brown fox jumps over the lazy dog")
      #    = 0xde7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9

      message = "The quick brown fox jumps over the lazy dog"
      key = "a2V5" # "key" -> base64
      signature = "3nybhbi3iqa8ino29wqQcBydtNk="

      expect(GoogleMapsService::Client.sign_hmac(key, message)).to eq(signature)
    end
  end

  # This test assumes that the time to run a mocked query is
  # relatively small, eg a few milliseconds. We define a rate of
  # 3 queries per second, and run double that, which should take at
  # least 1 second but no more than 2.
  context 'with total request is double of queries per second' do
    let(:queries_per_second) { 3 }
    let(:total_request) { queries_per_second * 2 }
    let(:client)  do
      GoogleMapsService::Client.new(key: api_key, queries_per_second: queries_per_second)
    end

    before(:example) do
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/.*/).
        to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, :body => '{"status":"OK","results":[]}')
    end

    it 'should take between 1-2 seconds' do
      start_time = Time.now
      total_request.times do
        client.geocode(address: "Sesame St.")
      end
      end_time = Time.now
      expect(end_time - start_time).to be_between(1, 2).inclusive
    end
  end


  context 'with client id and secret' do
    let(:client) do
      client = GoogleMapsService::Client.new(client_id: 'foo', client_secret: 'a2V5')
    end

    before(:example) do
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/.*/).
        to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, :body => '{"status":"OK","results":[]}')
    end

    it 'should be signed' do
      client.geocode(address: 'Sesame St.')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?address=Sesame+St.&client=foo&signature=fxbWUIcNPZSekVOhp2ul9LW5TpY=')).to have_been_made
    end
  end

  context 'without api key and client secret pair' do
    it 'should raise ArgumentError' do
      client = GoogleMapsService::Client.new
      expect { client.directions("Sydney", "Melbourne") }.to raise_error ArgumentError
    end
  end

  context 'with invalid api key' do
    let(:client) do
      client = GoogleMapsService::Client.new(key: "AIzaINVALID")
    end

    before(:example) do
      json = <<EOF
{
  "error_message": "The provided API key is invalid.",
  "routes": [],
  "status": "REQUEST_DENIED"
}
EOF
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/.*/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: json)
    end

    it 'should raise GoogleMapsService::Error::RequestDeniedError' do
      expect { client.directions(origin: "Sydney", destination: "Melbourne") }.to raise_error GoogleMapsService::Error::RequestDeniedError
    end
  end

  context 'with over query limit' do
    before(:example) do
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/geocode\/.*/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OVER_QUERY_LIMIT"}').then
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
    end

    it 'should make request twice' do
      results = client.geocode(address: 'Sydney')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&address=Sydney' % api_key)).to have_been_made.times(2)
    end
  end

  context 'with server error' do
    before(:example) do
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/geocode\/.*/)
        .to_return(:status => 500, body: 'Internal server error.').then
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
    end

    it 'should make request twice' do
      results = client.geocode(address: 'Sydney')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&address=Sydney' % api_key)).to have_been_made.times(2)
    end
  end

  context 'with connection failed' do
    before(:example) do
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/geocode\/.*/)
        .to_raise(Hurley::ConnectionFailed)
    end

    it 'should raise Hurley::ConnectionFailed' do
      expect { client.geocode(address: 'Sydney') }.to raise_error Hurley::ConnectionFailed
    end
  end
end