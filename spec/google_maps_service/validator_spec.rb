require 'spec_helper'
require 'date'

describe GoogleMapsService::Validator do
  describe '.travel_mode' do
    context 'with valid travel mode' do
      it 'should return travel mode' do
        [:driving, :walking, :bicycling, :transit].each do |mode|
          expect(GoogleMapsService::Validator.travel_mode(mode)).to eq(mode)
        end
        ['driving', 'walking', 'bicycling', 'transit'].each do |mode|
          expect(GoogleMapsService::Validator.travel_mode(mode)).to eq(mode)
        end
      end
    end

    context 'with invalid travel mode' do
      it 'should raise ArgumentError' do
        expect { GoogleMapsService::Validator.travel_mode('dreaming') }.to raise_error ArgumentError
      end
    end
  end

  describe '.avoid' do
    context 'with valid route restriction' do
      it 'should return route restriction' do
        [:tolls, :highways, :ferries].each do |mode|
          expect(GoogleMapsService::Validator.avoid(mode)).to eq(mode)
        end
        ['tolls', 'highways', 'ferries'].each do |mode|
          expect(GoogleMapsService::Validator.avoid(mode)).to eq(mode)
        end
      end
    end

    context 'with invalid travel mode' do
      it 'should raise ArgumentError' do
        expect { GoogleMapsService::Validator.avoid('people') }.to raise_error ArgumentError
      end
    end
  end
end