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
    # @return [String]
    def sign_hmac(secret, payload)
      require 'base64'
      require 'hmac'
      require 'hmac-sha1'

      secret = secret.encode('ASCII')
      payload = payload.encode('ASCII')

      # Decode the private key
      raw_key = Base64.urlsafe_decode64(secret)

      # Create a signature using the private key and the URL
      sha1 = HMAC::SHA1.new(raw_key)
      sha1 << payload
      raw_signature = sha1.digest()

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

    # The unreserved URI characters (RFC 3986)
    UNRESERVED_SET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"

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

        if h.length == 2 and !h.match(/[^A-Za-z0-9]/)
          c = h.to_i(16).chr

          if UNRESERVED_SET.include?(c)
            parts[i] = c + parts[i][2..-1]
          else
            parts[i] = "%#{parts[i]}"
          end
        else
          parts[i] = "%#{parts[i]}"
        end
      end

      return parts.join
    end
  end
end