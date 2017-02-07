require 'simplecov'
SimpleCov.start

require 'pry'
require 'minitest/autorun'


$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jekyll_rake'

# Added this line so SimpleCov tracks all files, not just the ones we require explicitly
# TODO: Is this a good idea? Will always load all files which could slow things down
# Could be temporary until we actually get a good level of tests
Dir.glob("./lib/**/*").select{|f| File.file? f}.each{|f| require f}

