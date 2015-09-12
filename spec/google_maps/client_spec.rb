require 'spec_helper'

describe GoogleMaps::Client do
  include_context 'HTTP client'

  context '.urlencode' do
    it 'should only encode non-reserved characters' do
      encoded_params = GoogleMaps::Client.urlencode_params([["address", "=Sydney ~"]])
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

      expect(GoogleMaps::Client.sign_hmac(key, message)).to eq(signature)
    end
  end

  context 'without api key and client secret pair' do
    it 'should raise ArgumentError' do
      client = GoogleMaps::Client.new
      expect { client.directions("Sydney", "Melbourne") }.to raise_error ArgumentError
    end
  end

  context 'with invalid api key' do
    let(:client) do
      client = GoogleMaps::Client.new(key: "AIzaINVALID")
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

    it 'should raise GoogleMaps::AuthorizationError' do
      expect { client.directions("Sydney", "Melbourne") }.to raise_error GoogleMaps::AuthorizationError
    end
  end

  context 'with client id and secret' do
    let(:client) do
      client = GoogleMaps::Client.new(client_id: 'foo', client_secret: 'a2V5')
    end

    before(:example) do
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/.*/).
         to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, :body => '{"status":"OK","results":[]}')
    end

    it 'should be signed' do
      client.geocode('Sesame St.')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?address=Sesame+St.&client=foo&signature=fxbWUIcNPZSekVOhp2ul9LW5TpY=')).to have_been_made
    end
  end
end