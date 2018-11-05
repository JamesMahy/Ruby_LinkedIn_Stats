class Color_Map
  attr_reader :map

  def initialize(image)
    @map = {
      'red' => 0,
      'brown' => 0,
      'orange' => 0,
      'yellow' => 0,
      'green' => 0,
      'blue' => 0,
      'purple' => 0,
      'pink' => 0,
      'black' => 0,
      'grey' => 0,
      'white' => 0
    }

    colors = image.color_profile
    colors.each do |color|
      #puts "#{color.count} #{color.red}, #{color.green}, #{color.blue} - #{color.name}"
      begin
        @map[color.name] += color.count
      rescue StandardError
        puts "#{color.red}, #{color.green}, #{color.blue} - #{color.name}"
      end
    end
  end

  def dominant_colors
    sorted = @map.sort_by{ |key, value| value }
    [sorted[10][0], sorted[9][0], sorted[8][0]]
  end

end