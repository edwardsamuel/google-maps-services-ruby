module GoogleMaps
  # Base error, capable of wrapping another
  class Error < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
    end
  end

  # An exception that is raised if a redirect is required
  class RedirectError < Error
  end

  # A 401 HTTP error occurred.
  class AuthorizationError < Error
  end

  # A 4xx class HTTP error occurred.
  class ClientError < Error
  end

  # A 4xx class HTTP error occurred.
  class RateLimitError < Error
  end

  # A 5xx class HTTP error occurred.
  class ServerError < Error
  end

  # An API error occured.
  class ApiError < Error
  end
end