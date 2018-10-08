require 'mini_magick'
require 'json'
require 'open-uri'
require 'fileutils'
require 'sqlite3'

$database = SQLite3::Database.new 'data/db.db'

module MiniMagick
  # Extends the image class to include the greyscale? method
  class Image
    # Adapted from https://www.imagemagick.org/discourse-server/viewtopic.php?t=19580&start=15
    def greyscale?
      result = run_command('convert', path, '-colorspace', 'HSI',
                           '-channel', 'g', '-separate', '+channel',
                           '-format', '%[fx:mean]', 'info:').to_f

      return true unless result > 0

      false
    end
  end
end

# Person class
class Person
  attr_reader :name, :occupation, :public_identifier, :image_root, :image, :greyscale_image

  def initialize(name:, occupation:, public_identifier:, image_root:, image:)
    @name = name
    @occupation = occupation
    @public_identifier = public_identifier
    @image_root = image_root
    @image = image
    @greyscale_image = false

    download_image
    image_path = "#{Dir.pwd}/#{get_local_image_path(true)}"

    unless image_path.nil? || @image.nil?
      i = MiniMagick::Image.open(image_path)
      @greyscale_image = i.greyscale?
    end

    Person.save(self)
  end

  def image_uri
    "#{@image_root}#{@image}"
  end

  def get_local_image_path(exists)
    path = "data/images/#{@public_identifier}.jpg"
    !exists || File.file?("#{Dir.pwd}/#{path}") ? path : nil
  end

  def download_image
    future_file = "#{Dir.pwd}/#{get_local_image_path(false)}"
    if @image_root && @image
      begin
        unless File.file?(future_file)
          puts "Downloading: #{image_uri}"
          tempfile = File.open(image_uri)
          IO.copy_stream(tempfile, future_file)
        end
      rescue OpenURI::HTTPError
        FileUtils.cp('wizard_color.jpg', future_file)
      end
    else
      FileUtils.cp('wizard_color.jpg', future_file)
    end
  end

  def self.save(person)
    existing = Person.get_by_public_identifier(person.public_identifier)
    unless existing # rubocop:disable Style/GuardClause
      $database.execute('INSERT INTO people (id, name, occupation, image, greyscale) VALUES (?, ?, ?, ?, ?)',
                        [
                          person.public_identifier,
                          person.name,
                          person.occupation,
                          person.get_local_image_path(true),
                          person.greyscale_image ? 1 : 0
                      ])
    end
  end

  def self.get_by_public_identifier(public_identifier)
    $database.execute( 'select * from people WHERE id = ?',
                       [public_identifier]) do |row|
      return row
    end
    nil
  end
end

def process_person(person)
  if person && person['firstName'] # rubocop:disable Style/GuardClause

    person_name = "#{person['firstName']} #{person['lastName']}"
    occupation = person['occupation']
    public_identifier = person['publicIdentifier']
    image_root = nil
    image = nil

    if person['picture']
      image_root = person['picture']['rootUrl']
      image = person['picture']['artifacts'][0]['fileIdentifyingUrlPathSegment']
    end

    person = Person.new(name: person_name,
                        occupation: occupation,
                        public_identifier: public_identifier,
                        image_root: image_root,
                        image: image)
    person

  end
end

def process_data_set(data_set)
  elements_array = data_set['included']
  elements_array.each { |person| process_person(person) }
end

def process_json_file
  file = File.read('data/data.json')
  arr = JSON.parse(file)

  arr.each { |data_set| data_set ? process_data_set(data_set) : nil }
end

#process_json_file()