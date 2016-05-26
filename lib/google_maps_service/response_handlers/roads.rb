require 'multi_json'

module GoogleMapsService
  # Google Maps Service Roads response handler
  module RoadsResponseHandler
    module_function

    # Extract and parse body response as hash.
    # Throw an error if there is something wrong with the response.
    #
    # @param [Object] response Web API response.
    #
    # @return [Hash] Response body as hash. The hash key will be symbolized.
    def decode_response_body(response)
      begin
        body = MultiJson.load(response.body, symbolize_keys: true)
      rescue
        if response.status_code == 200
          raise Error::ApiError.new(response), 'Received a malformed response.'
        end
        DefaultResponseHandler.check_response_status_code(response)
      end
      check_body_error(response, body)
    end

    # Check response body for error status.
    #
    # @param [Object] response Response object.
    # @param [Hash] body Response body.
    #
    # @return [void]
    def check_body_error(response, body)
      return body if response.status_code == 200
      raise_body_error(response, body[:error]) if body[:error]
      raise Error::ApiError.new(response), 'Unknown error'
    end

    # Raise an error based on error body.
    #
    # @param [Object] response Response object.
    # @param [Hash] roads_error Error status body.
    #
    # @return [void]
    def raise_body_error(response, roads_error)
      error_class =
        case roads_error[:status]
        when 'INVALID_ARGUMENT' then invalid_argument_error(roads_error)
        when 'PERMISSION_DENIED' then Error::RequestDeniedError
        when 'RESOURCE_EXHAUSTED' then Error::RateLimitError
        else Error::ApiError
        end
      raise error_class.new(response), roads_error[:message] if error_class
    end

    # Raise an invalid argument error based on error message.
    #
    # @param [Hash] roads_error Response body.
    #
    # @return [void]
    def invalid_argument_error(roads_error)
      if roads_error[:message] == 'The provided API key is invalid.'
        Error::RequestDeniedError
      else
        Error::InvalidRequestError
      end
    end
  end
end
