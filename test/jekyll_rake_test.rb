require 'test_helper'
require 'jekyll_rake'
require 'pry'

class JekyllRakeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::JekyllRake::VERSION
  end

  def test_it_does_something_useful
    JekyllRake::ScreenCap.new("test_in", "test_out")
  end
end
