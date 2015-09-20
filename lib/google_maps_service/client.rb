require 'uri'
require 'hurley'
require 'multi_json'
require 'retriable'
require 'thread'

require 'google_maps_service/errors'
require 'google_maps_service/convert'
require 'google_maps_service/directions'
require 'google_maps_service/distance_matrix'
require 'google_maps_service/elevation'
require 'google_maps_service/geocoding'
require 'google_maps_service/roads'
require 'google_maps_service/time_zone'

module GoogleMapsService

  # Core client functionality, common across all API requests (including performing
  # HTTP requests).
  class Client
    # Default user agent
    USER_AGENT = "GoogleGeoApiClientRuby/#{GoogleMapsService::VERSION}"

    # Default Google Maps Web Service base endpoints
    DEFAULT_BASE_URL = 'https://maps.googleapis.com'

    # Errors those could be retriable.
    RETRIABLE_ERRORS = [GoogleMapsService::Error::ServerError, GoogleMapsService::Error::RateLimitError]

    include GoogleMapsService::Directions
    include GoogleMapsService::DistanceMatrix
    include GoogleMapsService::Elevation
    include GoogleMapsService::Geocoding
    include GoogleMapsService::Roads
    include GoogleMapsService::TimeZone

    # Secret key for accessing Google Maps Web Service.
    # Can be obtained at https://developers.google.com/maps/documentation/geocoding/get-api-key#key
    # @return [String]
    attr_accessor :key

    # Client id for using Maps API for Work services.
    # @return [String]
    attr_accessor :client_id

    # Client secret for using Maps API for Work services.
    # @return [String]
    attr_accessor :client_secret

    # Timeout across multiple retriable requests, in seconds.
    # @return [Integer]
    attr_accessor :retry_timeout

    # Number of queries per second permitted.
    # If the rate limit is reached, the client will sleep for
    # the appropriate amount of time before it runs the current query.
    # @return [Integer]
    attr_reader :queries_per_second

    # Construct Google Maps Web Service API client.
    #
    # This gem uses [Hurley](https://github.com/lostisland/hurley) as internal HTTP client.
    # You can configure `Hurley::Client` through `request_options` and `ssl_options` parameters.
    # You can also directly get the `Hurley::Client` object via {#client} method.
    #
    # @example Setup API keys
    #   gmaps = GoogleMapsService::Client.new(key: 'Add your key here')
    #
    # @example Setup client IDs
    #   gmaps = GoogleMapsService::Client.new(
    #       client_id: 'Add your client id here',
    #       client_secret: 'Add your client secret here'
    #   )
    #
    # @example Setup time out and QPS limit
    #   gmaps = GoogleMapsService::Client.new(
    #       key: 'Add your key here',
    #       retry_timeout: 20,
    #       queries_per_second: 10
    #   )
    #
    # @example Request behind proxy
    #   request_options = Hurley::RequestOptions.new
    #   request_options.proxy = Hurley::Url.parse 'http://user:password@proxy.example.com:3128'
    #
    #   gmaps = GoogleMapsService::Client.new(
    #       key: 'Add your key here',
    #       request_options: request_options
    #   )
    #
    # @option options [String] :key Secret key for accessing Google Maps Web Service.
    #   Can be obtained at https://developers.google.com/maps/documentation/geocoding/get-api-key#key.
    # @option options [String] :client_id Client id for using Maps API for Work services.
    # @option options [String] :client_secret Client secret for using Maps API for Work services.
    # @option options [Integer] :retry_timeout Timeout across multiple retriable requests, in seconds.
    # @option options [Integer] :queries_per_second Number of queries per second permitted.
    #
    # @option options [Hurley::RequestOptions] :request_options HTTP client request options. See https://github.com/lostisland/hurley/blob/master/lib/hurley/options.rb.
    # @option options [Hurley::SslOptions] :ssl_options HTTP client SSL options. See https://github.com/lostisland/hurley/blob/master/lib/hurley/options.rb.
    def initialize(**options)
      @key = options[:key] || GoogleMapsService.key
      @client_id = options[:client_id] || GoogleMapsService.client_id
      @client_secret = options[:client_secret] || GoogleMapsService.client_secret
      @retry_timeout = options[:retry_timeout] || GoogleMapsService.retry_timeout || 60
      @queries_per_second = options[:queries_per_second] || GoogleMapsService.queries_per_second
      @request_options = options[:request_options] || GoogleMapsService.request_options
      @ssl_options = options[:ssl_options] || GoogleMapsService.ssl_options

      # Prepare "tickets" for calling API
      if @queries_per_second
        @sent_times = SizedQueue.new @queries_per_second
        @queries_per_second.times do
          @sent_times << 0
        end
      end
    end

    # Get the current HTTP client.
    # @return [Hurley::Client]
    def client
      @client ||= new_client
    end

    protected

    # Create a new HTTP client.
    # @return [Hurley::Client]
    def new_client
      client = Hurley::Client.new

      @request_options.each_pair {|key, value| client.request_options[key] = value } if @request_options
      @ssl_options.each_pair {|key, value| client.ssl_options[key] = value } if @ssl_options

      client.request_options.query_class = Hurley::Query::Flat
      client.header[:user_agent] = USER_AGENT
      client
    end

    def get(path, params, base_url: DEFAULT_BASE_URL, accepts_client_id: true, custom_response_decoder: nil)
      url = base_url + generate_auth_url(path, params, accepts_client_id)

      Retriable.retriable timeout: @retry_timeout, on: RETRIABLE_ERRORS do |try|
        # Get/wait the request "ticket" if QPS is configured
        # Check for previous request time, it must be more than a second ago before calling new request
        if @sent_times
          elapsed_since_earliest = Time.now - @sent_times.pop
          sleep(1 - elapsed_since_earliest) if elapsed_since_earliest.to_f < 1
        end

        begin
          response = client.get url
        ensure
          # Release request "ticket"
          @sent_times << Time.now if @sent_times
        end

        return custom_response_decoder.call(response) if custom_response_decoder
        decode_response_body(response)
      end
    end

    # Extract and parse body response as hash. Throw an error if there is something wrong with the response.
    #
    # @param [Hurley::Response] response Web API response.
    #
    # @return [Hash] Response body as hash. The hash key will be symbolized.
    def decode_response_body(response)
      check_response_status_code(response)

      body = MultiJson.load(response.body, :symbolize_keys => true)

      case body[:status]
      when 'OK', 'ZERO_RESULTS'
        return body
      when 'OVER_QUERY_LIMIT'
        raise GoogleMapsService::Error::RateLimitError.new(response), body[:error_message]
      when 'REQUEST_DENIED'
        raise GoogleMapsService::Error::RequestDeniedError.new(response), body[:error_message]
      when 'INVALID_REQUEST'
        raise GoogleMapsService::Error::InvalidRequestError.new(response), body[:error_message]
      else
        raise GoogleMapsService::Error::ApiError.new(response), body[:error_message]
      end
    end

    def check_response_status_code(response)
      case response.status_code
      when 200..300
        # Do-nothing
      when 301, 302, 303, 307
        message = sprintf('Redirect to %s', response.header[:location])
        raise GoogleMapsService::Error::RedirectError.new(response), message
      when 401
        message = 'Unauthorized'
        raise GoogleMapsService::Error::ClientError.new(response), message
      when 304, 400, 402...500
        message = 'Invalid request'
        raise GoogleMapsService::Error::ClientError.new(response), message
      when 500..600
        message = 'Server error'
        raise GoogleMapsService::Error::ServerError.new(response), message
      else
        message = 'Unknown error'
        raise GoogleMapsService::Error::BaseError.new(response), message
      end
    end

    # Returns the path and query string portion of the request URL,
    # first adding any necessary parameters.
    #
    # @param [String] path The path portion of the URL.
    # @param [Hash] params URL parameters.
    #
    # @return [String]
    def generate_auth_url(path, params, accepts_client_id)
      # Deterministic ordering through sorting by key.
      # Useful for tests, and in the future, any caching.
      if params.kind_of?(Hash)
        params = params.sort
      else
        params = params.dup
      end

      if accepts_client_id and @client_id and @client_secret
        params << ["client", @client_id]

        path = [path, self.class.urlencode_params(params)].join("?")
        sig = self.class.sign_hmac(@client_secret, path)
        return path + "&signature=" + sig
      end

      if @key
        params << ["key", @key]
        return path + "?" + self.class.urlencode_params(params)
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