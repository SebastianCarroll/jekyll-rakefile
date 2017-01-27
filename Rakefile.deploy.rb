# Include the lib files
cur_dir=File.dirname(File.readlink(__FILE__))
Dir.glob("./#{cur_dir}/libs/*").each{|f| require f}
Dir.glob("./#{cur_dir}/lib/*").select{|f| File.file? f}.each{|f| require f}

# coding: utf-8
task :default => :preview

load '_rake-configuration.rb' if File.exist?('_rake-configuration.rb')
load '_rake_configuration.rb' if File.exist?('_rake_configuration.rb')

$post_ext ||= ".markdown"
$post_dir ||= "_posts/"
$git_check ||= true
$git_autopush ||= false

# Tasks start here
###################
desc 'Clean up generated site'
task :clean do
  cleanup
end

desc 'Create a draft post'
task :new_draft, [:title, :content] do |t, args|
  # TODO: This global var is a terrible way of setting the directory.
  $post_dir = "_drafts/"
  create_new_post(t, args)
end

desc 'Copies latest screenshot into image directory and creates markdown includer'
task :insert_image do
  JekyllRake::ScreenCap.new
end

desc 'List unpublished drafts'
task :unpub do
  unpublished
end

desc 'Copy post from _drafts to _posts. All work is done in _drafts(even updates/fixes) and then new versions are published to _posts'
task :publish, [:draft_post]  do |t, args|
  draft_file = "_drafts/#{args.draft_post}"
  if File.file?(draft_file)
    commit_changed_draft(args.draft_post)
    publish_draft(draft_file)
  else
    puts "#{draft_file} doesn't exist"
  end
end

desc 'Preview on local machine (server with --auto)'
task :preview => :clean do
  jekyll('serve --watch --drafts')
end
task :serve => :preview

desc 'Show the file changed since last deploy to stdout'
task :list_changes do |t, args|
  content = list_file_changed
  puts content
end

desc 'Check links for site already running on localhost:4000'
task :check_links do
  check_links
end

# Tasks flagged for removal here
###################
desc 'Build for deployment (but do not deploy)'
task :build, [:deployment_configuration] => :clean do |t, args|
  args.with_defaults(:deployment_configuration => 'deploy')
  config_file = "_config_#{args[:deployment_configuration]}.yml"

  if rake_running then
    puts "\n\nWarning! An instance of rake seems to be running (it might not be *this* Rakefile, however).\n"
    puts "Building while running other tasks (e.g., preview), might create a website with broken links.\n\n"
    puts "Are you sure you want to continue? [Y|n]"

    ans = STDIN.gets.chomp
    exit if ans != 'Y' 
  end

  compass('compile')
  jekyll("build --config _config.yml,#{config_file}")
end

desc 'Build and deploy to remote server'
task :deploy, [:deployment_configuration] => :build do |t, args|
  args.with_defaults(:deployment_configuration => 'deploy')
  config_file = "_config_#{args[:deployment_configuration]}.yml"

  text = File.read("_config_#{args[:deployment_configuration]}.yml")
  matchdata = text.match(/^deploy_dir: (.*)$/)
  if matchdata

    if git_requires_attention("master") then
      puts "\n\nWarning! It seems that the local repository is not in sync with the remote.\n"
      puts "This could be ok if the local version is more recent than the remote repository.\n"
      puts "Deploying before committing might cause a regression of the website (at this or the next deploy).\n\n"
      puts "Are you sure you want to continue? [Y|n]"

      ans = STDIN.gets.chomp
      exit if ans != 'Y' 
    end

    deploy_dir = matchdata[1]
    sh "rsync -avz --delete _site/ #{deploy_dir}"
    time = Time.new
    File.open("_last_deploy.txt", 'w') {|f| f.write(time) }
    %x{git add -A && git commit -m "autopush by Rakefile at #{time}" && git push} if $git_autopush
  else
    puts "Error! deploy_url not found in _config_deploy.yml"
    exit 1
  end
end

# TODO: remove deploy
# - rename this to deploy
# - refactor to:
# -- see if all submodules are pushed and up to date
# -- deploy to github
desc 'Build and deploy to github'
task :deploy_github => :build do |t, args|
  # TODO: investigate this. Looks like passing in arges without the brackets
  args.with_defaults(:deployment_configuration => 'deploy')
  config_file = "_config_#{args[:deployment_configuration]}.yml"

  # TODO: What is this doing? What requires attention?
  if git_requires_attention("gh_pages") then
    puts "\n\nWarning! It seems that the local repository is not in sync with the remote.\n"
    puts "This could be ok if the local version is more recent than the remote repository.\n"
    puts "Deploying before committing might cause a regression of the website (at this or the next deploy).\n\n"
    puts "Are you sure you want to continue? [Y|n]"

    ans = STDIN.gets.chomp
    exit if ans != 'Y' 
  end

  # TODO: Add a line here to also push submodule as it will fail the github pages build
  %x{git add -A && git commit -m "autopush by Rakefile at #{time}" && git push origin gh_pages} if $git_autopush

  time = Time.new
  File.open("_last_deploy.txt", 'w') {|f| f.write(time) }
end

desc 'Create a post listing all changes since last deploy'
task :post_changes do |t, args|
  content = list_file_changed
  # Create a post with changes since last push
  Rake::Task["create_post"].invoke(Time.new.strftime("%Y-%m-%d %H:%M:%S"), "Recent Changes", nil, content)
end

