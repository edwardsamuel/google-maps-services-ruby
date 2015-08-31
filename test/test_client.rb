require 'minitest_helper'
require 'date'

class ClientTest < Minitest::Test

  def test_urlencode
    encoded_params = GoogleMaps::Client.urlencode_params([["address", "=Sydney ~"]])
    assert_equal("address=%3DSydney+~", encoded_params)
  end

  def test_hmac
    # From http://en.wikipedia.org/wiki/Hash-based_message_authentication_code
    #
    # HMAC_SHA1("key", "The quick brown fox jumps over the lazy dog")
    #    = 0xde7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9

    message = "The quick brown fox jumps over the lazy dog"
    key = "a2V5" # "key" -> base64
    signature = "3nybhbi3iqa8ino29wqQcBydtNk="

    assert_equal(signature, GoogleMaps::Client.sign_hmac(key, message))
  end
end