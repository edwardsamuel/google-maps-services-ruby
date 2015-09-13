module GoogleMapsService
  module Error
    # Base error, capable of wrapping another
    class BaseError < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end

    # An exception that is raised if a redirect is required
    class RedirectError < BaseError
    end

    # A 4xx class HTTP error occurred.
    class ClientError < BaseError
    end

    # A 5xx class HTTP error occurred.
    class ServerError < BaseError
    end

    # An API error occured.
    class ApiError < BaseError
    end

    # Requiered query is missing
    class InvalidRequestError < ApiError
    end

    # Over quota.
    class RateLimitError < ApiError
    end

    # An unathorized error occurred. It might be caused by invalid key/secret or invalid access.
    class RequestDeniedError < ApiError
    end
  end
end