require "mini_magick"
require "json"
require "open-uri"
require "fileutils"

module MiniMagick
  class Image
    # Adapted from https://www.imagemagick.org/discourse-server/viewtopic.php?t=19580&start=15
    def is_grayscale
      result = run_command("convert", "#{path}","-colorspace", "HSI", "-channel", "g", "-separate", "+channel", "-format", "%[fx:mean]", "info:").to_f
      if result > 0
        return false
      else
        return true
      end
    end
  end
end

class Person
  attr_reader :name, :occupation, :public_identifier, :image_root, :image

  def initialize(name:, occupation:, public_identifier:, image_root:, image:)
    @name = name
    @occupation = occupation
    @public_identifier = public_identifier
    @image_root = image_root
    @image = image

    download_image

  end

  def get_image_uri
    "#{@image_root}#{@image}"
  end

  def get_local_image_path(exists)
    path = "#{Dir.pwd}/data/images/#{@public_identifier}.jpg"
    if !exists || File.file?(path)
      return path
    end
    return nil
  end

  def download_image
    future_file = get_local_image_path(false)
    if @image_root && @image
      begin
        if !File.file?(future_file)
          puts "Downloading: #{get_image}"
          tempfile = open(get_image)
          IO.copy_stream(tempfile, future_file)
        end
      rescue OpenURI::HTTPError
          FileUtils.cp('wizard_color.jpg', future_file)
      end
    else
      FileUtils.cp('wizard_color.jpg', future_file)
    end
  end

end

def process_person (person)
  if person && person['firstName']

    person_name = "#{person['firstName']} #{person['lastName']}"
    occupation = person['occupation']
    public_identifier = person['publicIdentifier']

    if person['picture']
      image_root = person['picture']['rootUrl']
      image = person['picture']['artifacts'][0]['fileIdentifyingUrlPathSegment']
    end

    person = Person.new(name: person_name, occupation: occupation, public_identifier: public_identifier, image_root: image_root, image: image)

    image_path = person.get_local_image_path(true)
    if image_path != nil
      image = MiniMagick::Image.open(image_path)
      puts "#{person.occupation} - #{image.is_grayscale}"
    end

    return person

  end
end

def process_dataset (dataset)
  elements_array = dataset["included"]
  elements_array.each do |person|
    person_object = process_person(person)
    if person_object

    end
  end
end

def process_jsonfile
  file = File.read("data/data.json")
  arr = JSON.parse(file)

  arr.each {|dataset|
    if dataset
      process_dataset(dataset)
    end
  }
end

#image = MiniMagick::Image.open("wizard_greyscale.png")
#puts image.is_grayscale
#
#

process_jsonfile

puts "hello"

