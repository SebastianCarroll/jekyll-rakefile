module JekyllRake
  class Post 
    attr_reader :file, :content, :title

    def initialize(t, args, dir)
      check_title(args.title)
      check_date(args.date)

      post_title = JekyllRake::Utils.titleise(args.title)

      post_date = get_post_date(args.date)

      set_post_dir_and_yaml_cat(args.category, dir)

      filename = get_unique_filename(post_title, post_date)

      write_new_draft(filename, post_title, post_date, args)

      @content = args.content
      @file = File.join(@post_dir, filename)
      @title = post_title
    end

    def write_new_draft(filename, post_title, post_date, args)
      File.open(@post_dir + filename, 'w') do |f|
        f.puts "---"
        f.puts "title: \"#{post_title}\""
        f.puts "layout: default"
        f.puts @yaml_cat if @yaml_cat != nil
        f.puts "date: #{post_date}"
        f.puts "---"
        f.puts ""
        f.puts "\# #{post_title}" # Make the heading and title the same as a default
        f.puts args.content if args.content != nil
      end 
      puts "Post created under \"#{@post_dir}#{filename}\""
    end

    def get_post_date(date)
      # TODO: What is this? Too complex
      post_date = (date != "" and date != "nil" and not date.nil?) ? date : Time.new.strftime("%Y-%m-%d %H:%M:%S %Z")
    end

    def  get_unique_filename(post_title, post_date)
      # TODO: Global Variable
      filename = post_date[0..9] + "-" + JekyllRake::Utils.slugify(post_title) + $post_ext

      # TODO: refactor - very difficult to understand without the comment
      # generate a unique filename appending a number
      i = 1
      while File.exists?(@post_dir + filename) do
        filename = post_date[0..9] + "-" +
          File.basename(JekyllRake::Utils.slugify(post_title)) + "-" + i.to_s +
          $post_ext
        i += 1
      end
      filename
    end

    def  set_post_dir_and_yaml_cat(category, dir)
      # the destination directory is <<category>>/dir, if category is non-nil
      # and the directory exists; dir otherwise (a category tag is added in
      # the post body, in this case)
      # Written like this to deal with category being nil
      if category and Dir.exists?(File.join(category, dir)) then
        @post_dir = posts
        @yaml_cat = nil
      else
        @post_dir = dir
        @yaml_cat = category ? "category: #{category}\n" : nil
      end
    end

    def check_title(title)
      if title == nil then
        puts "Error! title is empty"
        puts "Usage: create_post[title,content,date,category]"
        puts "DATE and CATEGORY are optional"
        puts "DATE is in the form: YYYY-MM-DD; use nil or empty for today's date"
        puts "CATEGORY is a string; nil or empty for no category"
        exit 1
      end
    end

    def check_date(date)
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
    end

    def usage
      puts "Usage: create_post[date,title,category,content]"
      puts "DATE and CATEGORY are optional"
      puts "DATE is in the form: YYYY-MM-DD; use nil or the empty string for today's date"
      puts "CATEGORY is a string; nil or empty for no category"
      puts ""

      # TODO: Broken as not passed in. Necessary?
      title = args.title || "title"

      puts "Examples: create_post[\"\",\"#{title}\"]"
      puts "          create_post[nil,\"#{title}\"]"
      puts "          create_post[,\"#{title}\"]"
      puts "          create_post[#{Time.new.strftime("%Y-%m-%d")},\"#{title}\"]"
    end
  end
end
