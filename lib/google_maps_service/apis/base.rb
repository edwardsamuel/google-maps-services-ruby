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
        converter = GoogleMapsService::Convert
        keys.each do |key|
          if params[key]
            params[key] = converter.send(options[:with], params[key])
          end
        end
      end

      def validate(params, *keys, **options)
        validator = GoogleMapsService::Validator
        keys.each do |key|
          if params[key]
            params[key] = validator.send(options[:with], params[key])
          end
        end
      end
    end
  end
end
