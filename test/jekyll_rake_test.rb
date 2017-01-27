require 'test_helper'
require 'jekyll_rake'
require 'pry'

class JekyllRakeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::JekyllRake::VERSION
  end

  def test_it_throws_error_if_no_image_present
    # TODO: Update exception to something more meaningful
    assert_raises(Exception) {
      JekyllRake::ScreenCap.new("test_in", "test_out")
    }
  end
end
