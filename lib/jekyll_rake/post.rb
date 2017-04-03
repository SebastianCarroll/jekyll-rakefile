module JekyllRake
  class Post 
    attr_reader :file, :content, :title

    def initialize(t, args, dir)
      @title = parse_title(args.title)
      @date = parse_date(args.date)
      @content = args.content
      @category = args.category

      # TODO: This method is still out of place
      set_post_dir_and_yaml_cat(dir)
      @file = write_new_draft
    end

    # TODO: No error handling
    def write_new_draft()
      filename = get_unique_filename
      full_path = File.join(@post_dir, filename)
      File.open(full_path, 'w') do |f|
        f.puts "---"
        f.puts "title: \"#{@title}\""
        f.puts "layout: default"
        f.puts @yaml_cat if @yaml_cat != nil
        f.puts "date: #{@date}"
        f.puts "---"
        f.puts ""
        f.puts "\# #{@title}" # Make the heading and title the same as a default
        f.puts @content if @content != nil
      end 
      puts "Post created under \"#{full_path}\""
      full_path
    end

    def  get_unique_filename()
      # TODO: Remove Global Variable reliance
      filename = JekyllRake::Utils.slugify(@title) + $post_ext

      # TODO: refactor - very difficult to understand without the comment
      # generate a unique filename appending a number
      # TODO: Maybe just throw an error if that name already exists? This is what seems to be done elsewhere 
      i = 1
      while File.exists?(@post_dir + filename) do
        filename = @date[0..9] + "-" +
          File.basename(JekyllRake::Utils.slugify(@title)) + "-" + i.to_s +
          $post_ext
        i += 1
      end
      filename
    end

    # the destination directory is <<category>>/dir, if category is non-nil
    # and the directory exists; dir otherwise (a category tag is added in
    # the post body, in this case)
    def  set_post_dir_and_yaml_cat(dir)
      # Written like this to deal with category being nil
      if @category and Dir.exists?(File.join(@category, dir)) then
        @post_dir = File.join(@category, dir)
        @yaml_cat = nil
      else
        @post_dir = dir
        @yaml_cat = @category ? "category: #{@category}\n" : nil
      end
    end

    def parse_title(title)
      if title == nil then
        puts "Error! title is empty"
        puts "Usage: create_post[title,content,date,category]"
        puts "DATE and CATEGORY are optional"
        puts "DATE is in the form: YYYY-MM-DD; use nil or empty for today's date"
        puts "CATEGORY is a string; nil or empty for no category"
        exit 1
      end
      JekyllRake::Utils.titleise(title)
    end

    def parse_date(date)
      # This looks cleaner but logic is incorrect
      #if (date.nil? ||
      #    date.empty? ||
      #    date.match(/[0-9]+-[0-9]+-[0-9]+/).nil?) then
      if (date != nil and
          date != "nil" and
          date != "" and
          date.match(/[0-9]+-[0-9]+-[0-9]+/) == nil) then
        puts "Error: Date not understood"
        usage
        exit 1
      end
      # TODO: What is this? Too complex
      (date != "" and date != "nil" and not date.nil?) ? date : Time.new.strftime("%Y-%m-%d %H:%M:%S %Z")
    end

    def usage
      puts "Usage: create_post[date,title,category,content]"
      puts "DATE and CATEGORY are optional"
      puts "DATE is in the form: YYYY-MM-DD; use nil or the empty string for today's date"
      puts "CATEGORY is a string; nil or empty for no category"
      puts ""

      # TODO: Add logic here to account for nul title?
      puts "Examples: create_post[\"\",\"#{@title}\"]"
      puts "          create_post[nil,\"#{@title}\"]"
      puts "          create_post[,\"#{@title}\"]"
      puts "          create_post[#{Time.new.strftime("%Y-%m-%d")},\"#{@title}\"]"
    end
  end
end
