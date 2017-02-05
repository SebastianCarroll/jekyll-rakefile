module JekyllRake
  class Post 
    class << self
      def create(t, args, dir)
        check_title(args.title)
        check_date(args.date)

        post_title = JekyllRake::Utils.titleise(args.title)
        post_date = (args.date != "" and args.date != "nil" and not args.date.nil?) ? args.date : Time.new.strftime("%Y-%m-%d %H:%M:%S %Z")

        # the destination directory is <<category>>/dir, if category is non-nil
        # and the directory exists; dir otherwise (a category tag is added in
        # the post body, in this case)
        post_category = args.category
        if post_category and Dir.exists?(File.join(post_category, dir)) then
          post_dir = File.join(post_category, dir)
          yaml_cat = nil
        else
          post_dir = dir
          yaml_cat = post_category ? "category: #{post_category}\n" : nil
        end

        filename = post_date[0..9] + "-" + JekyllRake::Utils.slugify(post_title) + $post_ext

        # generate a unique filename appending a number
        i = 1
        while File.exists?(post_dir + filename) do
          filename = post_date[0..9] + "-" +
            File.basename(JekyllRake::Utils.slugify(post_title)) + "-" + i.to_s +
            $post_ext
          i += 1
        end

        # the condition is not really necessary anymore (since the previous
        # loop ensures the file does not exist)
        if not File.exists?(post_dir + filename) then
          File.open(post_dir + filename, 'w') do |f|
            f.puts "---"
            f.puts "title: \"#{post_title}\""
            f.puts "layout: default"
            f.puts yaml_cat if yaml_cat != nil
            f.puts "date: #{post_date}"
            f.puts "---"
            f.puts ""
            f.puts "\# #{post_title}" # Make the heading and title the same as a default
            f.puts args.content if args.content != nil
          end  

          puts "Post created under \"#{post_dir}#{filename}\""
          #" TODO: Find out how to customise Launchservices and change back to Open
          #sh "vim \"#{post_dir}#{filename}\"" if args.content == nil
        else
          #puts "A post with the same name already exists. Aborted."
        end
        # puts "You might want to: edit #{dir}#{filename}"

        #commit_new_content post_title
        [post_title, args.content, File.join(post_dir, filename)]
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
        if (date.nil? &&
            date.empty? &&
            date.match(/[0-9]+-[0-9]+-[0-9]+/).nil?) then
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
end
