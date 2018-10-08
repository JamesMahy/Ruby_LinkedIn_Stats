require 'mini_magick'
require 'json'
require 'open-uri'
require 'fileutils'
require 'sqlite3'

require_relative  'mini_magick.rb'
require_relative  'person.rb'

$database = SQLite3::Database.new 'data/db.db'

def process_json_file
  file = File.read('data/data.json')
  arr = JSON.parse(file)

  arr.each do |data_set|
    if data_set
      elements_array = data_set['included']
      elements_array.each { |person| Person.process_json(person) }
    end
  end
end

#process_json_file()