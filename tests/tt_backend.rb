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

    # Test the behaviour of the tell method on a new backend instance.
    #
    # Make sure that before any seek, the position in the stream is
    # zeroed out.
    def test_tell_new
      assert_nothing_raised do
        assert_equal 0, @backend.tell
      end
    end

    # Test the behaviour of the seek and tell methods for forward
    # seeks.
    #
    # This test ensures the correct behaviour of seek and tell
    # functions with valid parameters. Both absolute and relative
    # seeks are tested.
    #
    # The reverse seeking (starting from end) is not tested since it
    # might not be implemented (and is never implemented for now).
    def test_seek_tell_forward
      # We know that the data we use for test is at exactly 1KiB in
      # size, so we can seek around up to that.
      assert_nothing_raised do
        # Seek to the middle of the file, check that the value returned
        # by the seek method is always zero, and check that the reported
        # position is the expected one.
        assert_equal 0, @backend.seek(512)
        assert_equal 512, @backend.tell

        # Seek relatively to current position, check that the value
        # returned by the seek method is always zero, and check that the
        # reported position is the expected one.
        assert_equal 0, @backend.seek(256, ::IO::SEEK_CUR)
        assert_equal 768, @backend.tell

      end
    end

    # Test the behaviour of the seek and tell methods for backward
    # seeks.
    def test_seek_tell_backward
      # We don't want to assert on the moving to the middle of the
      # file, since that is tested by another test, if it fails,
      # consider it an error rather than a failure.
      @backend.seek(512)
      
      assert_nothing_raised do
        # Try first a relative seek backward, by providing a negative
        # amount for the seek.
        assert_equal 0, @backend.seek(-256, ::IO::SEEK_CUR)
        assert_equal 256, @backend.tell

        # Then try an absolute backward seek by providing a position
        # that is known to be before the current position.
        assert_equal 0, @backend.seek(128)
        assert_equal 128, @backend.tell
      end
    end

    # Test the behaviour of the seek and tell methods for seeks with
    # no movement.
    #
    # Since no movements at all (a relative seek of zero bytes, or an
    # absolute seek to the same position) might be special cases for
    # some backends, especially if seek is emulated, test these cases
    # explicitly.
    def test_seek_tell_no
      # We don't want to assert on the moving to the middle of the
      # file, since that is tested by another test, if it fails,
      # consider it an error rather than a failure.
      @backend.seek(512)
      
      assert_nothing_raised do
        # Try first a relative seek of amount zero
        assert_equal 0, @backend.seek(0, ::IO::SEEK_CUR)
        assert_equal 512, @backend.tell

        # Try then an absolute seek to the position returned by #tell.
        assert_equal 0, @backend.seek(@backend.tell)
        assert_equal 512, @backend.tell

        # Try then an absolute seek to the known arbitrary position.
        assert_equal 0, @backend.seek(512)
        assert_equal 512, @backend.tell
      end
    end

    # Test behaviour when seeking over the end of the data.
    #
    # TODO: this should probably be replaced with an exception since
    # it won't be possible to do with compressed data backends
    def test_seek_over
      assert_nothing_raised do
        # Seeking over the end of the file is allowed, but the reads
        # will fail since we're over the end of file.
        assert_equal 0, @backend.seek(2048)
        # TODO: test that the reads do return EOF
      end
    end

    # TEST FOR INVALID SEEK REQUESTS
    
    # Test negative absolute seeks (they have to throw InvalidSeek)
    def test_seek_absolute_negative
      assert_raise Bombe::InvalidSeek do
        @backend.seek(-1)
      end
    end

    # Test relative seeks that would move before the start of data
    def test_seek_relative_negative
      # First move to a known position ...
      assert_nothing_raised do
        @backend.seek(128)
      end

      assert_equal 128, @backend.tell
      
      # ... then try to go back before the start of data
      assert_raise Bombe::InvalidSeek do
        @backend.seek(-256, IO::SEEK_CUR)
      end
    end

    # TODO need to test reverse seeks, but needs a way to check if
    # they are supported first or it would fail for backends not
    # supporting them.

    # Test non-integer amount values: strings and floating point
    # values (should throw TypeError).
    def test_seek_invalid_amount
      assert_raise TypeError do
        @backend.seek("foo")
      end

      assert_raise TypeError do
        @backend.seek(0.1)
      end
    end
    
    # Test invalis whence values (should throw InvalidWhence)
    def test_seek_invalid_whence
      assert_raise InvalidWhence do
        @backend.seek(10, "bar")
      end
    end
  end
end
