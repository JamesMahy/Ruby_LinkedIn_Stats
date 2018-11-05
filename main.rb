require 'mini_magick'
require 'json'
require 'open-uri'
require 'fileutils'


require_relative 'classes/interface.rb'
require_relative 'classes/abstract_sql_database_provider.rb'
require_relative 'classes/color.rb'
require_relative 'classes/color_map.rb'
require_relative 'classes/mysql_database_provider.rb'
require_relative 'classes/mini_magick.rb'
require_relative 'classes/person.rb'

$database = MYSQLDatabaseProvider.new
$database.connect

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



exit


i = MiniMagick::Image.open("data/images/richdibbins.jpg")
map = Color_Map.new(i)

puts map.dominant_colorss
exit

Dir.glob('data/images/*.jpg').each do |file|

  next unless !file.equal?('..') && !file.equal?('.')

  i = MiniMagick::Image.open("#{file}")
  map = Color_Map.new(i)

  puts file
  puts map.dominant_color

end

