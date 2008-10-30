# This file is part of ruby-bombe
# Copyright 2008 Diego "Flameeyes" Pettenò <flameeyes@gmail.com>
#
# ruby-bombe is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with ruby-bombe.  If not, see
# <http://www.gnu.org/licenses/>.

require 'test/unit'
require 'tempfile'

module Bombe
  class TT_Backend < Test::Unit::TestCase
    attr_reader :file_content
    attr_reader :file_path
    
    # Create a temporary file with 1 KiB of random data.
    #
    # Note: this function expects a Unix system with /dev/urandom,
    # like Linux.
    def setup
      @tmpf = Tempfile.new(self.class.name)
      randf = File.new("/dev/urandom")
      
      @file_content = randf.read(1024)
      @file_path = @tmpf.path
      @tmpf.write @file_content
      @tmpf.close
    end

    # Close the backend instance and remove the temporary file.
    #
    # The backend closing is done here so that it is certain that it
    # will always be tested.
    def teardown
      @backend.close
      @tmpf.unlink
    end

    # Test the class of the backend instance.
    #
    # We want to ensure that all the backends inherit from
    # Bombe::Backend::Base. The tests for the specific backends can
    # test this further by overriding this test.
    def test_class
      assert_kind_of Bombe::Backend::Base, @backend
    end

    # Test the presence of the basic methods for a backend
    #
    # We want to ensure that all the methods that we're going to rely
    # on are present in the instance.
    def test_basics
      assert_respond_to @backend, :seek
      assert_respond_to @backend, :tell
      assert_respond_to @backend, :close
    end
  end
end
