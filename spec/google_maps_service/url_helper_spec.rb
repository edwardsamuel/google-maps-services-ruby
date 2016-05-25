require 'spec_helper'

describe GoogleMapsService::UrlHelper do
  context '.urlencode' do
    it 'should only encode non-reserved characters' do
      encoded_params = GoogleMapsService::UrlHelper.urlencode_params([["address", "=Sydney ~"]])
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

      expect(GoogleMapsService::UrlHelper.sign_hmac(key, message)).to eq(signature)
    end
  end
end