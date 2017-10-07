module JekyllRake
  class Folder
    def initialize(name)
      @folder = name
    end

    def list
      Dir.glob(@folder + "/*")
        .select{|f| File.file? f}
        .map{|f| File.basename f}
        .to_set
    end
  end
end
