require 'test_helper'
require 'jekyll_rake/folder'
require 'fileutils'
require 'pry'

class FolderTest < Minitest::Test

  def setup
    @filenames = %w(draft1.md draft38.text posted)
    @folder = "test_draft_folder"
    FileUtils.mkdir_p @folder
    @filenames.each{|f| File.write("#{@folder}/#{f}", 'cool blog info')}
  end

  def test_return_all_files_in_folder
    filenames_actual = JekyllRake::Folder.new(@folder).list
    filenames_actual.zip(@filenames).each do |f1,f2|
      assert_equal f1, f2
    end
  end

  def teardown
    FileUtils.rm_r @folder
  end
end
