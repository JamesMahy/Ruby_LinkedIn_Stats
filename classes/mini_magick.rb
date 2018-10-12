
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

    def color_profile
      result = run_command('convert', path, '-format', '"%c"', 'histogram:info:')
      puts result

      m = result.scan /([0-9]+): \(([0-9 ]+),([0-9 ]+),([ 0-9]+)\)/ism
      ret = []

      m.each do |color_profile|
        ret.push(Color.new(color_profile[0].to_i, color_profile[1].to_i, color_profile[2].to_i, color_profile[3].to_i))
      end

      ret

    end

  end
end