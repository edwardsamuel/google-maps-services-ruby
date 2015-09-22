require 'base64'
require 'uri'

module GoogleMapsService

  # Helper for handling URL.
  module Url
    module_function

    # Returns a base64-encoded HMAC-SHA1 signature of a given string.
    #
    # @param [String] secret The key used for the signature, base64 encoded.
    # @param [String] payload The payload to sign.
    #
    # @return [String] Base64-encoded HMAC-SHA1 signature
    def sign_hmac(secret, payload)
      secret = secret.encode('ASCII')
      payload = payload.encode('ASCII')

      # Decode the private key
      raw_key = Base64.urlsafe_decode64(secret)

      # Create a signature using the private key and the URL
      digest = OpenSSL::Digest.new('sha1')
      raw_signature = OpenSSL::HMAC.digest(digest, raw_key, payload)

      # Encode the signature into base64 for url use form.
      signature =  Base64.urlsafe_encode64(raw_signature)
      return signature
    end

    # URL encodes the parameters.
    # @param [Hash, Array<Array>] params The parameters
    # @return [String]
    def urlencode_params(params)
      unquote_unreserved(URI.encode_www_form(params))
    end

    # Un-escape any percent-escape sequences in a URI that are unreserved
    # characters. This leaves all reserved, illegal and non-ASCII bytes encoded.
    #
    # @param [String] uri
    #
    # @return [String]
    def unquote_unreserved(uri)
      parts = uri.split('%')

      (1..parts.length-1).each do |i|
        h = parts[i][0..1]

        if h =~ /^([\h]{2})(.*)/ and c = $1.to_i(16).chr and UNRESERVED_SET.include?(c)
          parts[i] = c + $2
        else
          parts[i] = '%' + parts[i]
        end
      end

      parts.join
    end

    # The unreserved URI characters (RFC 3986)
    UNRESERVED_SET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
  end
end