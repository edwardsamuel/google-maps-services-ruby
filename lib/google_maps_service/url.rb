require 'base64'
require 'uri'

module GoogleMapsService
  # Helper for handling URL.
  module Url
    module_function

    # Returns the path and query string portion of the request URL,
    # first adding any necessary parameters.
    #
    # @param [String] path The path portion of the URL.
    # @param [Hash] params URL parameters.
    # @param [Boolean] accepts_client_id Sign the request using API {#keys}
    #   instead of {#client_id}.
    #
    # @return [String]
    def generate_auth_url(path, params, accepts_client_id)
      # Deterministic ordering through sorting by key.
      # Useful for tests, and in the future, any caching.
      params = if params.is_a?(Hash)
                 params.sort
               else
                 params.dup
               end

      return build_client_id_url(path, params) if accepts_client_id &&
                                                  @client_id && @client_secret
      return build_api_key_url(path, params) if @key
      raise ArgumentError, 'Must provide API key for this API.' \
            'It does not accept enterprise credentials.'
    end

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
      Base64.urlsafe_encode64(raw_signature)
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

      (1..parts.length - 1).each do |i|
        parts[i] = unquote_part(parts[i])
      end

      parts.join
    end

    def unquote_part(str)
      /^(?<w1>[\h]{2})(?<w2>.*)/ =~ str[0..1]
      if UNRESERVED_SET.include?(w1.to_i(16).chr)
        w1.to_i(16).chr + w2
      else
        '%' + str
      end
    end

    # The unreserved URI characters (RFC 3986)
    UNRESERVED_SET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' \
                     'abcdefghijklmnopqrstuvwxyz' \
                     '0123456789-._~'.freeze

    protected

    def build_client_id_url(path, params)
      params << ['client', @client_id]
      path = [path, urlencode_params(params)].join('?')
      "#{path}&signature=#{sign_hmac(@client_secret, path)}"
    end

    def build_api_key_url(path, params)
      params << ['key', @key]
      "#{path}?#{urlencode_params(params)}"
    end
  end
end
