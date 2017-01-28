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
      JekyllRake::ScreenCap.new("fake_in", "fake_out")
    }
  end

  def test_correct_image_returned
    puts "Cureent dir #{Dir.pwd}"
    # setup test dir
    test_dir = "test"
    in_dir = File.join(test_dir, "in")
    out_dir = File.join(test_dir, "out")
    filename = "Screen Shot 2016-06-29 at 3.54.14 PM.png"
    FileUtils.mkdir_p in_dir
    FileUtils.mkdir_p out_dir
    content = "test content"
    new_filename = "test2"

    # setup test files
    File.open(File.join(in_dir, filename), 'w') {|f| f.puts content}

    # Run screencap
    JekyllRake::ScreenCap.new(in_dir, out_dir, new_filename)

    # check file moved
    expected = File.join(out_dir, new_filename) + File.extname(filename)
    assert(File.exists?(expected), "File not foind in correct place")

    # clean up - remove dirs
    FileUtils.rm_rf in_dir
    FileUtils.rm_rf out_dir
  end
end
