module JekyllRake
  class Utils
    def self.slugify(title)
      # strip characters and whitespace to create valid filenames, also lowercase
      return title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end

    # TODO: Migrate slugify from '-' to '_'. Need to write script to migrate filenames
    def self.slugify_lower(title)
      # strip characters and whitespace to create valid filenames, also lowercase
      return title.downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '')
    end
    
    def self.titleise(input)
      require 'titleize'
      input.titleize
    end
  end
end
