# TODO: This is an issue with load paths. Need to Fix this
#require "jekyll_rake/version"


module JekyllRake
  class JekyllRake
    def test()
      puts "test!!!"
    end
  end

  class Utils
    def self.slugify (title)
      # strip characters and whitespace to create valid filenames, also lowercase
      return title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end


  # Handle inserting screen shots into markdown and copying those to the images dir
  class ScreenCap
    def initialize(in_dir, out_dir, name=nil)
      @in_dir = in_dir
      @out_dir = out_dir
      @name = name

      get_latest_image
      prompt_for_name unless name
      move_image
    end

    # TODO: make 'last' one date time rather than filename
    def get_latest_image()
      @latest_image = Dir.glob("#{@in_dir}/Screen Shot*").last
      #binding.pry
      if @latest_image.nil?
        msg = "No images available in directory #{@in_dir}"
        puts "Error: " + msg
        # TODO: Make this exception more meaningful
        raise Exception.new(msg)
      end
    end

    def prompt_for_name()
      puts "What would you like to call the image (no ext)?"
      @name ||= $stdin.gets.strip
    end

    def move_image()
      ext = @latest_image.split('.').last

      new_file = "#{@out_dir}/#{Utils.slugify(@name)}.#{ext}"
      new_file_path = File.join(Dir.pwd, new_file)

      require 'fileutils'
      FileUtils.mv(@latest_image, new_file)
      puts "![#{@name}]({{ site.baseurl }}/#{new_file})"
    end
  end
end
