class Color
  attr_reader :count, :red, :green, :blue

  def initialize(count=0, red = 0, green = 0, blue = 0)
    @count = count
    @red = red
    @green = green
    @blue = blue
  end

  def name
    red_blue_ratio_percentage = (@red.to_f / @blue.to_f) * 100
    red_green_ratio_percentage = (@red.to_f / @green.to_f) * 100
    blue_green_ratio_percentage = (@blue.to_f / @green.to_f) * 100

    if red_blue_ratio_percentage.to_f.nan?
      red_blue_ratio_percentage = 0.0
    end

    if red_green_ratio_percentage.to_f.nan?
      red_green_ratio_percentage = 0.0
    end

    if blue_green_ratio_percentage.to_f.nan?
      blue_green_ratio_percentage = 0.0
    end

    begin
      if red_blue_ratio_percentage.between?(95, 105) &&
         red_green_ratio_percentage.between?(95, 105) &&
         blue_green_ratio_percentage.between?(95, 105)

        if @red <= 20
          return 'black'
        elsif @red <= 240
          return 'grey'
        end

        return 'white'
      end

      if @red > @green && @red >= @blue # Red'ish
        if @green <= 220 && @green == @blue
          return 'red'
        elsif red_blue_ratio_percentage.between?(95,150) && blue_green_ratio_percentage > 88
          return 'pink'
        elsif @red < 220 && @green > @blue
          return 'brown'
        elsif @green != @blue
          return 'orange'
        end
      elsif @red == @green && @red > @blue
        return 'yellow'
      elsif @green > @red && @green >= @blue && blue_green_ratio_percentage < 99
        return 'green'
      elsif (@blue > @red && @blue >= @green) || blue_green_ratio_percentage > 98
        return 'purple' unless @red == @green || red_blue_ratio_percentage <= 95

        return 'blue'
      end
    rescue StandardError
      puts "hello"
    end
  end
  'black'
end
