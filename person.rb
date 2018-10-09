# Person class
class Person
  attr_reader :name, :occupation, :public_identifier, :image_root, :image, :greyscale_image

  def initialize(name:, occupation:, public_identifier:, image_root:, image:, greyscale:false, download_the_image: true, save:true)
    @name = name
    @occupation = occupation
    @public_identifier = public_identifier
    @image_root = image_root
    @image = image
    @greyscale_image = greyscale

    if download_the_image
      download_image
      image_path = "#{Dir.pwd}/#{get_local_image_path(true)}"

      unless image_path.nil? || @image.nil?
        i = MiniMagick::Image.open(image_path)
        @greyscale_image = i.greyscale?
      end
    end

    Person.save(self) unless !save
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
      return Person.convert_db_row_to_person(row)
    end
    nil
  end

  def self.all
    people = []
    $database.execute('select * from people') do |row|
      person = Person.convert_db_row_to_person(row)
      people.push(person)
    end

    people
  end

  def self.convert_db_row_to_person(row)
    Person.new(name: row['name'], occupation: row['occupation'],
               public_identifier: row['id'], image_root: '', image: '',
               greyscale: (row['greyscale'].to_i ? true : false),
               download_the_image: false, save: false)
  end

  def self.process_json(person)
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

      Person.new(name: person_name, occupation: occupation,
                 public_identifier: public_identifier,
                 image_root: image_root, image: image)
    end
  end
end

