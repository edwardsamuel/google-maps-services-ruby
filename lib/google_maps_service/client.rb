require 'httpclient'
require 'retriable'
require 'thread'

require_relative './errors'
require_relative './convert'
require_relative './url_helper'
require_relative './response_handlers/default'
require_relative './apis'

module GoogleMapsService
  # Core client functionality, common across all API requests (including
  # performing HTTP requests).
  class Client
    # Default Google Maps Web Service base endpoints
    DEFAULT_BASE_URL = 'https://maps.googleapis.com'.freeze

    # Errors those could be retriable.
    RETRIABLE_ERRORS = [
      Error::ServerError,
      Error::RateLimitError
    ].freeze

    include Apis
    include UrlHelper

    # Secret key for accessing Google Maps Web Service.
    # Can be obtained at
    # https://developers.google.com/maps/documentation/geocoding/get-api-key#key.
    #
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
    # This gem uses [HTTPClient](https://github.com/nahi/httpclient) as internal
    # HTTP client.
    # You can access directly and configure `HTTPClient` instance
    # through {#raw_client}. Read more about `HTTPClient` in
    # http://www.rubydoc.info/gems/httpclient/HTTPClient.
    #
    # @example Setup API keys
    #   gmaps = Client.new(key: 'Add your key here')
    #
    # @example Setup client IDs
    #   gmaps = Client.new(
    #       client_id: 'Add your client id here',
    #       client_secret: 'Add your client secret here'
    #   )
    #
    # @example Setup time out and QPS limit
    #   gmaps = Client.new(
    #       key: 'Add your key here',
    #       retry_timeout: 20,
    #       queries_per_second: 10
    #   )
    #
    # @example Request behind proxy
    #   gmaps = Client.new(key: 'Add your key here')
    #   gmaps.raw_client.proxy = 'http://user:password@proxy.example.com:3128'
    #
    # @example Configure SSL certificate
    #   gmaps = Client.new(key: 'Add your key here')
    #   gmaps.raw_client
    #        .ssl_config
    #        .set_client_cert_file('cert.crt', 'private.key')
    #
    # @option options [String] :key Secret key for accessing
    #     Google Maps Web Service.
    #     Can be obtained at https://developers.google.com/maps/documentation/geocoding/get-api-key#key.
    # @option options [String] :client_id Client id for using
    #     Google Maps API for Work services.
    # @option options [String] :client_secret Client secret for using
    #     Google Maps API for Work services.
    # @option options [Integer] :retry_timeout Timeout across multiple retriable
    #     requests, in seconds.
    # @option options [Integer] :queries_per_second Number of queries per
    #     second permitted.
    def initialize(options = {})
      initialize_variables(options)
      initialize_query_tickets
    end

    # Get the current HTTP client.
    # @return [HTTPClient]
    def raw_client
      @raw_client ||= new_client
    end

    # Build the user agent header
    # @return [String]
    def user_agent
      @user_agent ||= 'google-maps-services-ruby/' \
                      "#{VERSION} " \
                      "(#{OS_VERSION})"
    end

    # Make API call.
    #
    # @param [String] path Url path.
    # @param [String] params Request parameters.
    # @param [String] base_url Base Google Maps Web Service API endpoint url.
    # @param [Boolean] accepts_client_id Sign the request using API {#keys}
    #    instead of {#client_id}.
    # @param [Method] custom_response_decoder Custom method
    #    to decode raw API response.
    #
    # @return [Object] Decoded response body.
    def get(path, params, options = {})
      base_url = options.fetch(:base_url, DEFAULT_BASE_URL)
      accepts_client_id = options.fetch(:accepts_client_id, true)
      response_handler = options.fetch(:response_handler,
                                       DefaultResponseHandler)

      url = base_url + generate_auth_url(path, params, accepts_client_id)
      retriable_get(url) do |response|
        response_handler.decode_response_body(response)
      end
    end

    protected

    def initialize_variables(options = {})
      [
        :key, :client_id, :client_secret,
        :retry_timeout, :queries_per_second,
        :request_options, :ssl_options, :connection
      ].each do |key|
        instance_variable_set(
          "@#{key}".to_sym,
          options[key] || GoogleMapsService.instance_variable_get("@#{key}")
        )
      end
    end

    # Initialize QPS queue. QPS queue is a "tickets" for calling API
    def initialize_query_tickets
      if @queries_per_second
        @qps_queue = SizedQueue.new @queries_per_second
        @queries_per_second.times { @qps_queue << 0 }
      end
    end

    # Create a new HTTP client.
    # @return [HTTPClient]
    def new_client
      HTTPClient.new(agent_name: user_agent)
    end

    def retriable_get(url)
      Retriable.retriable timeout: @retry_timeout, on: RETRIABLE_ERRORS do |_t|
        begin
          request_query_ticket
          response = raw_client.get url
        ensure
          release_query_ticket
        end
        yield(response)
      end
    end

    # Get/wait the request "ticket" if QPS is configured.
    # Check for previous request time, it must be more than a second ago
    # before calling new request.
    #
    # @return [void]
    def request_query_ticket
      if @qps_queue
        elapsed_since_earliest = Time.now - @qps_queue.pop
        sleep(1 - elapsed_since_earliest) if elapsed_since_earliest.to_f < 1
      end
    end

    # Release request "ticket".
    #
    # @return [void]
    def release_query_ticket
      @qps_queue << Time.now if @qps_queue
    end
  end
end
