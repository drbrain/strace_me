require 'rubygems'
require 'minitest/autorun'
require 'strace'

class TestStrace < MiniTest::Unit::TestCase

  def test_class_me_no_strace
    path = ENV['PATH']
    ENV['PATH'] = nil

    assert_raises Errno::ENOENT do
      Strace.me do end
    end
    
  ensure
    ENV['PATH'] = path
  end

end

