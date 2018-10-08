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