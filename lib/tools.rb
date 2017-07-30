def commit_new_content(title, dir)
  if dir.downcase.include? 'drafts'
    # TODO: Break this out to improve readability somehow
    # TODO: Do I want to be commiting all here?
    # Must have cd and cd .. in same sh command as sh wont maintain dir over calls
    sh "cd #{dir} && git add -A && git ci -m \"Add new draft: #{title}\" && cd .."
  end
end

def commit_changed_draft(title, draft_folder)
  # TODO: This fails if nothing to commit.
  # Not a big deal but if code further down the line fails, the changes will be commited however
  # the future code cannot be re-run. Could add a try catch?
  puts "Commiting draft version"
  sh("cd #{draft_folder}; git add #{title}; git ci -m \"Published new version of #{title}\"")
end

def publish_draft(draft_file)
  puts "Commiting published version"
  filename = File.basename draft_file
  post_file = "_posts/#{prepend_date filename}"
  require 'fileutils'
  FileUtils.mv(draft_file, post_file)
  sh("git add #{post_file}")
  sh("git ci -m \"Published new version of #{post_file}\"")
end

# Looks like date: in front matter overrides date of filename anyway
# We could just put the publish date here?
def prepend_date(filename)
  Time.new.strftime("%Y-%m-%d") + '-' + filename
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
def unpublished(draft_folder)
  drafts = filenames_in "#{draft_folder}/*"
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
