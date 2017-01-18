def create_new_post(t, args)
  if args.title == nil then
    puts "Error! title is empty"
    puts "Usage: create_post[title,content,date,category]"
    puts "DATE and CATEGORY are optional"
    puts "DATE is in the form: YYYY-MM-DD; use nil or empty for today's date"
    puts "CATEGORY is a string; nil or empty for no category"
    exit 1
  end
  if (args.date != nil and
      args.date != "nil" and
      args.date != "" and
      args.date.match(/[0-9]+-[0-9]+-[0-9]+/) == nil) then
    puts "Error: date not understood"
    puts "Usage: create_post[date,title,category,content]"
    puts "DATE and CATEGORY are optional"
    puts "DATE is in the form: YYYY-MM-DD; use nil or the empty string for today's date"
    puts "CATEGORY is a string; nil or empty for no category"
    puts ""

    title = args.title || "title"

    puts "Examples: create_post[\"\",\"#{args.title}\"]"
    puts "          create_post[nil,\"#{args.title}\"]"
    puts "          create_post[,\"#{args.title}\"]"
    puts "          create_post[#{Time.new.strftime("%Y-%m-%d")},\"#{args.title}\"]"
    exit 1
  end

  $post_dir = args.dir unless args.dir.nil?
  post_title = args.title
  post_date = (args.date != "" and args.date != "nil" and not args.date.nil?) ? args.date : Time.new.strftime("%Y-%m-%d %H:%M:%S %Z")

  # the destination directory is <<category>>/$post_dir, if category is non-nil
  # and the directory exists; $post_dir otherwise (a category tag is added in
  # the post body, in this case)
  post_category = args.category
  if post_category and Dir.exists?(File.join(post_category, $post_dir)) then
    post_dir = File.join(post_category, $post_dir)
    yaml_cat = nil
  else
    post_dir = $post_dir
    yaml_cat = post_category ? "category: #{post_category}\n" : nil
  end

  filename = post_date[0..9] + "-" + slugify(post_title) + $post_ext

  # generate a unique filename appending a number
  i = 1
  while File.exists?(post_dir + filename) do
    filename = post_date[0..9] + "-" +
      File.basename(slugify(post_title)) + "-" + i.to_s +
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
    # TODO: Find out how to customise Launchservices and change back to Open
    sh "vim \"#{post_dir}#{filename}\"" if args.content == nil
  else
    puts "A post with the same name already exists. Aborted."
  end
  # puts "You might want to: edit #{$post_dir}#{filename}"

  commit_new_content post_title
end

def commit_new_content(title)
  if $post_dir.downcase.include? 'drafts'
    # TODO: Break this out to improve readability somehow
    # TODO: Do I want to be commiting all here?
    # Must have cd and cd .. in same sh command as sh wont maintain dir over calls
    sh "cd _drafts && git add -A && git ci -m \"Add new draft: #{title}\" && cd .."
  end
end

def commit_changed_draft(title)
  puts "Commiting draft version"
  sh("cd _drafts; git add #{title}; git ci -m \"Published new version of #{title}\"")
end

def publish_draft(draft_file)
  puts "Commiting published version"
  post_file = "_posts/#{args.draft_post}"
  require 'fileutils'
  FileUtils.cp(draft_file, post_file)
  sh("git add #{post_file}")
  sh("git ci -m \"Published new version of #{post_file}\"")
end

desc 'Create a post'
task :create_post, [:title, :content, :date, :category] do |t, args|
  create_new_post(t, args)
end

def check_links
  begin
    require 'anemone'

    root = 'http://localhost:4000/'
    puts "Checking links with anemone ... "
    # check-links --no-warnings http://localhost:4000
    Anemone.crawl(root, :discard_page_bodies => true) do |anemone|
      anemone.after_crawl do |pagestore|
        broken_links = Hash.new { |h, k| h[k] = [] }
        pagestore.each_value do |page|
          if page.code != 200
            referrers = pagestore.pages_linking_to(page.url)
            referrers.each do |referrer|
              broken_links[referrer] << page
            end
          else
            puts "OK #{page.url}"
          end
        end
        puts "\n\nLinks with issues: "
        broken_links.each do |referrer, pages|
          puts "#{referrer.url} contains the following broken links:"
          pages.each do |page|
            puts "  HTTP #{page.code} #{page.url}"
          end
        end
      end
    end
    puts "... done!"

  rescue LoadError
    abort 'Install anemone gem: gem install anemone'
  end
end

#
# support functions for generating list of changed files
#

# TODO: Changed to list_files_changed - make plural for clarity
def list_file_changed
  content = "Files changed since last deploy:\n"
  # TODO: Refactor to use File.readlines.
  # NOTE: May not be able to as opening command not file
  # TODO: Refactor to use inject or join
  # TODO: Actually do I use any of this?
  IO.popen('find * -newer _last_deploy.txt -type f') do |io| 
    while (line = io.gets) do
      filename = line.chomp
      if user_visible(filename) then
        content << "* \"#{filename}\":{{site.url}}/#{file_change_ext(filename, ".html")}\n"
      end
    end
  end 
  content
end

# this is the list of files we do not want to show in changed files
EXCLUSION_LIST = [/.*~/, /_.*/, "javascripts?", "js", /stylesheets?/, "css", "Rakefile", "Gemfile", /s[ca]ss/, /.*\.css/, /.*.js/, "bower_components", "config.rb"]

# return true if filename is "visible" to the user (e.g., it is not javascript, css, ...)
def user_visible(filename)
  exclusion_list = Regexp.union(EXCLUSION_LIST)
  not filename.match(exclusion_list)
end 

def file_change_ext(filename, newext)
  if File.extname(filename) == ".textile" or File.extname(filename) == ".md" then
    filename.sub(File.extname(filename), newext)
  else  
    filename
  end
end

# Lists all unpublished posts
def unpublished
  drafts = filenames_in "_drafts/*"
  pubs = filenames_in "_posts/*"
  # return filenames in drafts but not in pubs
  (drafts - pubs).each{|f| puts f unless f == "README.md" }
end

#
# General support functions
#

# Get filenames in directory
def filenames_in(dir)
  Dir.glob(dir)
    .select{|f| File.file? f}
    .map{|f| File.basename f}
    .to_set
end

def slugify (title)
  # strip characters and whitespace to create valid filenames, also lowercase
  return title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
end

# remove generated site
def cleanup
  sh 'rm -rf _site'
  compass('clean')
end

# launch jekyll
def jekyll(directives = '')
  sh 'jekyll ' + directives
end

# launch compass
def compass(command = 'compile')
  (sh 'compass ' + command) if $compass
end

# check if there is another rake task running (in addition to this one!)
def rake_running
  `ps | grep 'rake' | grep -v 'grep' | wc -l`.to_i > 1
end

def git_local_diffs
  %x{git diff --name-only} != ""
end

def git_remote_diffs branch
  %x{git fetch}
  %x{git rev-parse #{branch}} != %x{git rev-parse origin/#{branch}}
end

def git_repo?
  %x{git status} != ""
end

def git_requires_attention branch
  $git_check and git_repo? and git_remote_diffs(branch)
end

# Class to handle inserting screen shots into markdown
class ScreenCap
  def initialize()
    move_image(get_latest_image, prompt_for_name)
  end

  # TODO: make 'last' one date time rather than filename
  def get_latest_image()
    Dir.glob("#{Dir.home}/Desktop/Screen Shot*").last
  end

  def prompt_for_name()
    puts "What would you like to call the image (no ext)?"
    name = $stdin.gets.strip
  end

  def move_image(image, name)
    ext = image.split('.').last

    # TODO: Make the filename snake but the reference camel
    new_file = "images/#{name}.#{ext}"
    new_file_path = File.join(Dir.pwd, new_file)

    require 'fileutils'
    FileUtils.mv(image, new_file)
    puts "![#{name}]({{ site.baseurl }}/#{new_file})"
  end

end
