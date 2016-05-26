require 'multi_json'

module GoogleMapsService
  # Default Google Maps Service response handler
  module DefaultResponseHandler
    module_function

    # Extract and parse body response as hash.
    # Throw an error if there is something wrong with the response.
    #
    # @param [Object] response Web API response.
    #
    # @return [Hash] Response body as `Hash`. The hash key will be symbolized.
    def decode_response_body(response)
      if response_ok?(response)
        body = MultiJson.load(response.body, symbolize_keys: true)
        check_body_error(response, body)
        body
      else
        check_response_status_code(response)
      end
    end

    # Check if whether HTTP response status code is success or not.
    #
    # @param [Object] response Web API response.
    #
    # @return [boolean] Return `true` if the status code is 2xx.
    def response_ok?(response)
      (200..300).cover?(response.status_code)
    end

    # Check HTTP response status code. Raise error if the status is not 2xx.
    #
    # @param [Object] response Web API response.
    def check_response_status_code(response)
      case response.status_code
      when 301, 302, 303, 307
        raise Error::RedirectError.new(response), 'Redirected'
      when 401
        raise Error::ClientError.new(response), 'Unauthorized'
      when 304, 400, 402...500
        raise Error::ClientError.new(response), 'Invalid request'
      when 500..600
        raise Error::ServerError.new(response), 'Server error'
      end
    end

    # Check response body for error status.
    #
    # @param [Object] response Response object.
    # @param [Hash] body Response body.
    #
    # @return [void]
    def check_body_error(response, body)
      error_class =
        case body[:status]
        when 'OK', 'ZERO_RESULTS' then nil
        when 'OVER_QUERY_LIMIT' then Error::RateLimitError
        when 'REQUEST_DENIED' then Error::RequestDeniedError
        when 'INVALID_REQUEST' then Error::InvalidRequestError
        else Error::ApiError
        end
      raise error_class.new(response), body[:error_message] if error_class
    end
  end
end
