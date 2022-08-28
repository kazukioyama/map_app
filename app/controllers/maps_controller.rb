class MapsController < ApplicationController
  protect_from_forgery
  require 'json'
  require 'csv'
  require 'uri'

  BASE_URL = 'https://maps.googleapis.com'
  API_KEY = Rails.application.credentials.web[:api_key]

  def index
  end

  def fetch_map_api
    municipality_address = params["city_name"]
    type = params["type"]
    lat_division = params["lat_division"].to_f
    lng_division = params["lng_division"].to_f
    csv_file_name = "sample.csv"
    max_lat, min_lat, max_lng, min_lng = fetch_municipality_location_range(municipality_address)
    map_data_json = fetch_all_marker(max_lat, min_lat, max_lng, min_lng, type, lat_division, lng_division, csv_file_name)
    render json: map_data_json
  end


  private
    def fetch_all_marker(max_lat, min_lat, max_lng, min_lng, type, lat_division, lng_division, csv_file_name)
      type = type
      lat = min_lat.dup
      lng = min_lng.dup
      count = 0
      lat_count = 0
      results_json = []
      while lat <= max_lat
        puts "<<<<<======== lat#{lat_count}順目 ========>>>>>"
        lng_count = 0
        while lng <= max_lng
          puts "======== #{count}順目, lng#{lng_count}順目, lat: #{lat}, lng: #{lng} place_api processing... ========"
          # fetch_marker_demo(lat, lng, type, csv_file_name)
          results_json << fetch_marker(lat, lng, type, csv_file_name)
          lng += lng_division
          puts '======== next lng ========'
          count += 1
          lng_count += 1
          break if count > 10
        end
        puts "<<<<<======== lat#{lat_count}順目終了 next lat ========>>>>>"
        lng = min_lng.dup
        lat += lat_division
        lat_count += 1
        break if count > 10 #中区＆中村区のリクエスト数10000件以内に抑えたいので
      end
      return results_json
    end

    def fetch_marker(lat, lng, type, csv_file_name)
      conn = ::Faraday.new(url: BASE_URL)
      location = "#{lat},#{lng}"
      type = type
      res = conn.get do |req|
        req.url '/maps/api/place/nearbysearch/json'
        req.params = {
          :location => location,
          :type => type,
          :rankby => 'distance',
          :language => 'ja',
          :key => API_KEY
        }
      end
      res_body_json = JSON.parse(res.body)
      results_json = res_body_json['results']
      results_json.each do |json|
        Lodging.create!(
          place_id: json['place_id'],
          lat: json['geometry']['location']['lat'],
          lng: json['geometry']['location']['lng'],
          name: json['name'],
          reference: json['reference'],
          types: json['types'],
          rating: json['rating'],
          vicinity: json['vicinity']
        )
      end
      return results_json
    end

    def fetch_municipality_location_range(address)
      conn = ::Faraday.new(url: BASE_URL)
      address = address
      res = conn.get do |req|
        req.url '/maps/api/geocode/json'
        req.params = {
          :address => address,
          :language => 'ja',
          :key => API_KEY
        }
      end
      res_body_json = JSON.parse(res.body)
      municipality_bounds = res_body_json['results'][0]['geometry']['bounds']
      max_lat = municipality_bounds['northeast']['lat']
      min_lat = municipality_bounds['southwest']['lat']
      max_lng = municipality_bounds['northeast']['lng']
      min_lng = municipality_bounds['southwest']['lng']

      return [max_lat, min_lat, max_lng, min_lng]
    end
end
