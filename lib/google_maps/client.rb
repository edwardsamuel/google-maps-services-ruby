require 'uri'

module GoogleMaps
  class Client
    USER_AGENT = "GoogleGeoApiClientRuby/#{GoogleMaps::VERSION}"
    DEFAULT_BASE_URL = "https://maps.googleapis.com"
    RETRIABLE_STATUSES = [500, 503, 504]

    # DEFAULT_CONNECTION_MIDDLEWARE = [
    #   Faraday::Request::Multipart,
    #   Faraday::Request::UrlEncoded,
    #   FaradayMiddleware::Mashify,
    #   FaradayMiddleware::ParseJson
    # ]

    #

    attr_reader :key, :client_id, :client_secret

    def initialize(options={})
      @key = options[:key] || GoogleMaps.key
      @client_id = options[:client_id] || GoogleMaps.client_id
      @client_secret = options[:key] || GoogleMaps.client_secret
      @ssl = options[:ssl] || GoogleMaps.ssl || Hash.new
      @connection_middleware = options[:connection_middleware] || GoogleMaps.connection_middleware || []
      @connection_middleware += DEFAULT_CONNECTION_MIDDLEWARE
    end

    # Returns the path and query string portion of the request URL,
    # first adding any necessary parameters.
    #
    # @param [String] path The path portion of the URL.
    # @param [Hash] params URL parameters.
    #
    # @return [String]
    def generate_auth_url(path, params, accepts_clientid)
      # Deterministic ordering through sorting by key.
      # Useful for tests, and in the future, any caching.
      if params.kind_of?(Hash)
        params = params.sort
      else
        params = params.dup
      end

      if accepts_clientid and @client_id and @client_secret
        params << ["client", @client_id]

        path = [path, urlencode_params(params)].join("?")
        sig = sign_hmac(@client_secret, path)
        return path + "&signature=" + sig
      end

      if @key
        params << ["key", @key]
        return path + "?" + urlencode_params(params)
      end

      raise ArgumentError, "Must provide API key for this API. It does not accept enterprise credentials."
    end



    # Returns a base64-encoded HMAC-SHA1 signature of a given string.
    #
    # @param [String] secret The key used for the signature, base64 encoded.
    # @param [String] payload The payload to sign.
    #
    # @return [String]
    def self.sign_hmac(secret, payload)
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
    def self.urlencode_params(params)
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
    def self.unquote_unreserved(uri)
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