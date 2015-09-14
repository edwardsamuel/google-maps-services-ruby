require 'spec_helper'

describe GoogleMapsService::DistanceMatrix do
  include_context 'HTTP client'

  before(:example) do
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/distancematrix\/.*/)
      .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
  end

  context 'basic params' do
    it 'should call Google Maps Web Service' do
      origins = ["Perth, Australia", "Sydney, Australia",
                 "Melbourne, Australia", "Adelaide, Australia",
                 "Brisbane, Australia", "Darwin, Australia",
                 "Hobart, Australia", "Canberra, Australia"]
      destinations = ["Uluru, Australia",
                      "Kakadu, Australia",
                      "Blue Mountains, Australia",
                      "Bungle Bungles, Australia",
                      "The Pinnacles, Australia"]

      matrix = client.distance_matrix(origins: origins, destinations: destinations)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/distancematrix/json?key=%s&origins=Perth%%2C+Australia%%7CSydney%%2C+Australia%%7CMelbourne%%2C+Australia%%7CAdelaide%%2C+Australia%%7CBrisbane%%2C+Australia%%7CDarwin%%2C+Australia%%7CHobart%%2C+Australia%%7CCanberra%%2C+Australia&destinations=Uluru%%2C+Australia%%7CKakadu%%2C+Australia%%7CBlue+Mountains%%2C+Australia%%7CBungle+Bungles%%2C+Australia%%7CThe+Pinnacles%%2C+Australia' % api_key)).to have_been_made
    end
  end

  context 'mixed params' do
    it 'should call Google Maps Web Service' do
      origins = ["Bobcaygeon ON", [41.43206, -81.38992]]
      destinations = [[43.012486, -83.6964149],
                      {lat: 42.8863855, lng: -78.8781627}]

      matrix = client.distance_matrix(origins: origins, destinations: destinations)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/distancematrix/json?key=%s&origins=Bobcaygeon+ON%%7C41.432060%%2C-81.389920&destinations=43.012486%%2C-83.696415%%7C42.886386%%2C-78.878163' % api_key)).to have_been_made
    end
  end

  context 'all params' do
    it 'should call Google Maps Web Service' do
      origins = ["Perth, Australia", "Sydney, Australia",
                 "Melbourne, Australia", "Adelaide, Australia",
                 "Brisbane, Australia", "Darwin, Australia",
                 "Hobart, Australia", "Canberra, Australia"]
      destinations = ["Uluru, Australia",
                      "Kakadu, Australia",
                      "Blue Mountains, Australia",
                      "Bungle Bungles, Australia",
                      "The Pinnacles, Australia"]

      matrix = client.distance_matrix(origins: origins, destinations: destinations,
                                          mode: 'driving',
                                          language: 'en-AU',
                                          avoid: 'tolls',
                                          units: 'imperial')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=Perth%%2C+Australia%%7CSydney%%2C+Australia%%7CMelbourne%%2C+Australia%%7CAdelaide%%2C+Australia%%7CBrisbane%%2C+Australia%%7CDarwin%%2C+Australia%%7CHobart%%2C+Australia%%7CCanberra%%2C+Australia&language=en-AU&avoid=tolls&mode=driving&key=%s&units=imperial&destinations=Uluru%%2C+Australia%%7CKakadu%%2C+Australia%%7CBlue+Mountains%%2C+Australia%%7CBungle+Bungles%%2C+Australia%%7CThe+Pinnacles%%2C+Australia' % api_key)).to have_been_made

    end
  end

  context 'lang param' do
    it 'should call Google Maps Web Service' do
      origins = ["Vancouver BC", "Seattle"]
      destinations = ["San Francisco", "Victoria BC"]

      matrix = client.distance_matrix(origins: origins, destinations: destinations,
                                          language: 'fr-FR',
                                          mode: 'bicycling')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/distancematrix/json?key=%s&language=fr-FR&mode=bicycling&origins=Vancouver+BC%%7CSeattle&destinations=San+Francisco%%7CVictoria+BC' %
                          api_key)).to have_been_made
    end
  end
end