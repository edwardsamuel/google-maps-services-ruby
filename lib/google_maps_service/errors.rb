module GoogleMapsService
  # Specific Google Maps Service error
  module Error
    # Base error, capable of wrapping another
    class BaseError < StandardError
      # HTTP response object
      # @return [Hurley::Response]
      attr_reader :response

      # Initialize error
      #
      # @param [Hurley::Response] response HTTP response.
      def initialize(response = nil)
        @response = response
      end
    end

    # The response redirects to another URL.
    class RedirectError < BaseError
    end

    # A 4xx class HTTP error occurred.
    # The request is invalid and should not be retried without modification.
    class ClientError < BaseError
    end

    # A 5xx class HTTP error occurred.
    # An error occurred on the server and the request can be retried.
    class ServerError < BaseError
    end

    # An unknown error occured.
    class UnknownError < BaseError
    end

    # General Google Maps Web Service API error occured.
    class ApiError < BaseError
    end

    # Requiered query is missing
    class InvalidRequestError < ApiError
    end

    # The quota for the credential is over limit.
    class RateLimitError < ApiError
    end

    # An unathorized error occurred. It might be caused by invalid key/secret or invalid access.
    class RequestDeniedError < ApiError
    end
  end
end