require 'test_helper'
require 'jekyll_rake/utils'

class JekyllRakeTest < Minitest::Test
  def test_slugify_lower
    test = "This is a Title - for testing!"
    expected = "this_is_a_title_-_for_testing"
    assert_equal expected, JekyllRake::Utils.slugify_lower(test)
  end

  def test_slugify
    test = "This is a Title - for testing!"
    expected = "this-is-a-title---for-testing"
    assert_equal expected, JekyllRake::Utils.slugify(test)
  end

  def test_titilize
    test = "this is a title - for testing!"
    expected = "This Is a Title - for Testing!"
    assert_equal expected, JekyllRake::Utils.titleise(test)
  end
end
