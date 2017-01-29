module JekyllRake
  class Utils
    def self.slugify (title)
      # strip characters and whitespace to create valid filenames, also lowercase
      return title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end
end
