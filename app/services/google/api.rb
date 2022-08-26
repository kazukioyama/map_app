require 'json'
require 'csv'
require 'uri'
require 'pry-byebug'
require 'faraday'

BASE_URL = 'https://maps.googleapis.com'
API_KEY = ''

def main(municipality_address, type, lat_division, lng_division, csv_file_name)
  start_time = Time.now
  max_lat, min_lat, max_lng, min_lng = fetch_municipality_location_range(municipality_address)
  set_csv_file(csv_file_name)
  map_data_json = fetch_all_marker(max_lat, min_lat, max_lng, min_lng, type, lat_division, lng_division, csv_file_name)
  # map_data_json = fetch_marker('35.19091029999989', '136.88729659999987', 'store', csv_file_name)
  puts '======== Processing completed. ========'
  p "処理時間 #{Time.now - start_time}s"
end

# 対象市区町村の緯度経度の範囲を取得する関数
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

# 範囲内で緯度経度を動かしてfetch_marker関数を回す関数
def fetch_all_marker(max_lat, min_lat, max_lng, min_lng, type, lat_division, lng_division, csv_file_name)
  type = type
  lat = min_lat.dup
  lng = min_lng.dup
  count = 0
  lat_count = 0
  while lat <= max_lat
    puts "<<<<<======== lat#{lat_count}順目 ========>>>>>"
    lng_count = 0
    while lng <= max_lng
      puts "======== #{count}順目, lng#{lng_count}順目, lat: #{lat}, lng: #{lng} place_api processing... ========"
      # fetch_marker_demo(lat, lng, type, csv_file_name)
      fetch_marker(lat, lng, type, csv_file_name)
      lng += lng_division
      puts '======== next lng ========'
      count += 1
      lng_count += 1
      break if count > 5000
    end
    puts "<<<<<======== lat#{lat_count}順目終了 next lat ========>>>>>"
    lng = min_lng.dup
    lat += lat_division
    lat_count += 1
    break if count > 5000 #中区＆中村区のリクエスト数10000件以内に抑えたいので
  end
end

# 対象位置＆対象type＆対象半径内のマーカー情報を取得する＆CSVに出力する関数
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
  output_csv_from_json(results_json, csv_file_name)
  return results_json
end

def fetch_marker_demo(lat, lng, type, csv_file_name)
  results_json = Hash.new
  File.open("sample.json") do |f|
    results_json = JSON.load(f)
  end
  output_csv_from_json(results_json, csv_file_name)
end

def set_csv_file(file_name)
  CSV.open(file_name, 'w') do |csv|
    csv << ['place_id', 'lat', 'lng', 'name', 'reference', 'types', 'rating', 'vicinity']
  end
end

# jsonデータをCSVファイルに出力(追加)する関数
def output_csv_from_json(results_json, file_name)
  CSV.open(file_name, 'a') do |csv|
    results_json.each do |json|
      csv << [
        json['place_id'],
        json['geometry']['location']['lat'],
        json['geometry']['location']['lng'],
        json['name'],
        json['reference'],
        json['types'],
        json['rating'],
        json['vicinity']
      ]
      puts "#{json['name']} outputted"
    end
  end
end




# # 以下標準入力

puts '市区町村名：'
municipality_address = gets.chomp
puts '対象type：'
type = gets.chomp
puts 'lat_division値：'
lat_division = gets.to_f
puts 'lng_division値：'
lng_division = gets.to_f
puts '出力するcsvファイル名：'
csv_file_name = gets.chomp
puts "市区町村名: #{municipality_address}  対象type: #{type}  ファイル名: #{csv_file_name}"
puts 'OKなら1を入力しろ'
ok_int = gets.to_i

if (ok_int == 1)
  main(municipality_address, type, lat_division, lng_division, csv_file_name)
end
