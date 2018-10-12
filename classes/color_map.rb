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
      puts "#{color.count} #{color.red}, #{color.green}, #{color.blue} - #{color.name}"
      begin
        @map[color.name] += color.count
      rescue StandardError
        puts "#{color.red}, #{color.green}, #{color.blue} - #{color.name}"
      end
    end
  end

  def dominant_color
    sorted = @map.sort_by{ |key, value| value }
    last = sorted.last
    if sorted[sorted.count - 2][1] >= (last[1] - 10) &&
       sorted[sorted.count - 2][1] <= (last[1] + 10) &&
       (last.equal?('white') || last.equal?('black'))
      sorted[sorted.count - 2][0]
    end
    sorted.last[0]
  end

end