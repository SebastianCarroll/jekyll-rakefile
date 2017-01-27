# TODO: This is an issue with load paths. Need to Fix this
#require "jekyll_rake/version"

module JekyllRake
  class JekyllRake
    def test()
      puts "test!!!"
    end
  end

  # Handle inserting screen shots into markdown and copying those to the images dir
  class ScreenCap
    def initialize(in_dir, out_dir)
      @in_dir = in_dir
      @out_dir = out_dir

      get_latest_image
      prompt_for_name
      move_image
    end

    # TODO: make 'last' one date time rather than filename
    def get_latest_image(img_dir)
      @latest_image = Dir.glob("#{@in_dir}/Screen Shot*").last
    end

    def prompt_for_name()
      puts "What would you like to call the image (no ext)?"
      @name = $stdin.gets.strip
    end

    def move_image()
      ext = @latest_image.split('.').last

      new_file = "#{@out_dir}/#{slugify(@name)}.#{ext}"
      new_file_path = File.join(Dir.pwd, new_file)

      require 'fileutils'
      FileUtils.mv(@latest_image, new_file)
      puts "![#{@name}]({{ site.baseurl }}/#{new_file})"
    end
  end
end
