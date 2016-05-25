require_relative '../validator'

module GoogleMapsService
  module Apis
    class Base
      def initialize(client)
        @client = client
      end

      protected

      def get(path, params, options = {})
        @client.get(path, params, options)
      end

      def convert(params, *keys, **options)
        assigner(GoogleMapsService::Convert, params, keys, options)
      end

      def validate(params, *keys, **options)
        assigner(GoogleMapsService::Validator, params, keys, options)
      end

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
