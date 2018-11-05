# Person class
class Person
  attr_reader :name, :occupation, :public_identifier, :image_root, :image
  attr_accessor :color1, :color2, :color3

  def initialize(name:, occupation:, public_identifier:, image_root:, image:, color1:'', color2:'', color3:'', download_the_image: true, save:true)
    @name = name.gsub(/[^A-Z0-9_\- ]+/i, '')
    @occupation = occupation.gsub(/[^A-Z0-9_\- ]+/i, '')
    @public_identifier = public_identifier
    @image_root = image_root
    @image = image
    @color1 = color1
    @color2 = color2
    @color3 = color3

    if download_the_image
      download_image
      image_path = "#{Dir.pwd}/#{local_image_path(true)}"

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

  def local_image_path(exists)
    path = "data/images/#{@public_identifier}.jpg"
    !exists || File.file?("#{Dir.pwd}/#{path}") ? path : nil
  end

  def download_image
    future_file = "#{Dir.pwd}/#{local_image_path(false)}"
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
    if existing # rubocop:disable Style/GuardClause
      begin
        $database.query('UPDATE people SET color1 = ?, color2 = ?, color3 = ? WHERE id = ?',
                        [
                          person.color1,
                          person.color2,
                          person.color3,
                          person.public_identifier
                        ])
      rescue StandardError
        puts "Something went wrong with saving #{person.public_identifier}"
      end
    else
      begin
        $database.query('INSERT INTO people (id, name, occupation, image,
                              color1, color2, color3)
                         VALUES (?, ?, ?, ?, ?, ?, ?)',
                        [
                          person.public_identifier,
                          person.name,
                          person.occupation,
                          person.local_image_path(true),
                          person.color1,
                          person.color2,
                          person.color3
                        ])
      rescue StandardError
        puts "Something went wrong with saving #{person.public_identifier}"
      end

    end
  end

  def self.get_by_public_identifier(public_identifier)
    $database.query( 'select * from people WHERE id = ?',
                     [public_identifier]) do |row|
      return Person.convert_db_row_to_person(row)
    end
    nil
  end

  def self.all
    people = []
    $database.query('select * from people') do |row|
      person = Person.convert_db_row_to_person(row)
      people.push(person)
    end
    people
  end

  def self.convert_db_row_to_person(row)
    Person.new(name: row['name'], occupation: row['occupation'],
               public_identifier: row['id'], image_root: '', image: '',
               color1: row['color1'],
               color2: row['color2'],
               color3: row['color3'],
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
        image = person['picture']['artifacts'][0]
        ['fileIdentifyingUrlPathSegment']

      end

      Person.new(name: person_name, occupation: occupation,
                 public_identifier: public_identifier,
                 image_root: image_root, image: image)
    end
  end

  def self.process_colors
    Person.all.each do |person|
      file = person.local_image_path(false)

      next if file.nil?

      i = MiniMagick::Image.open(file)
      map = Color_Map.new(i)
      colors = map.dominant_colors

      person.color1 = colors[0]
      person.color2 = colors[1]
      person.color3 = colors[2]

      Person.save(person)

    end
  end
end

