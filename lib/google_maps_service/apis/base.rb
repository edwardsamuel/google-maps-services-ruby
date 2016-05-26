require_relative '../validator'
require_relative '../../core_extensions/extract_options'

module GoogleMapsService
  module Apis
    # Base of API client. Wrap request and API parameter convertion/validation.
    #
    # @abstract
    class Base
      # Setup Base API client
      def initialize(client)
        @client = client
      end

      protected

      # Call HTTP client using GET method.
      #
      # @see GoogleMapsService::Client#get
      #
      # @param [String] path API endpoint path.
      # @param [String] params Request parameters.
      # @param [String] options HTTP Client optional parameters.
      #
      # @return [Hash] Processed body. The keys are symbolized.
      def get(path, params, options = {})
        @client.get(path, params, options)
      end

      # Replace some parameters based using converter.
      #
      # @param [Hash] params The parameters.
      # @param [Hash] args The keys of parameters.
      # @option options [String] with Converter method name.
      #
      # @return [Hash] The parameters itself.
      def convert(params, *args)
        options = args.extract_options!
        assigner(GoogleMapsService::Convert, params, args, options)
        params
      end

      # Replace some parameters based using validator.
      #
      # @param [Hash] params The parameters.
      # @param [Hash] args The keys of parameters.
      # @option options [String] with Validator method name.
      #
      # @return [Hash] The parameters itself.
      def validate(params, *args)
        options = args.extract_options!
        assigner(GoogleMapsService::Validator, params, args, options)
        params
      end

      # Replace some parameters based using modifier module .
      #
      # @param [Hash] modifier The modifier module name.
      # @param [Hash] params The parameters.
      # @param [Hash] keys The keys of parameters.
      # @option options [String] with Modifier method name.
      #
      # @return [Hash] The parameters itself.
      def assigner(modifier, params, keys, options)
        keys.each do |key|
          if params[key]
            params[key] = modifier.send(options[:with], params[key])
          end
        end
      end
    end
  end
end
