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

require 'bombe/backend_string'

module Bombe
  class TC_Backend_String < TT_Backend
    # Open the backend, this is called by the sub-classes that
    # actually implement tests
    def open(arg)
      @backend = Backend::String.new(arg)
    end

    # Specialise the class test, the backend instance is going to be
    # Backend::String as well as Backend::Base.
    def test_class
      super
      
      assert_kind_of Backend::String, @backend
    end

    class Standalone < Test::Unit::TestCase
      # Test the behaviour of the String backend when providing a
      # complex string (with NULL bytes and bytes with value 255.
      def test_string_complex
        assert_nothing_raised do
          Backend::String.new("\0foobar\255\255\255\0\0\0")
        end
      end
      
      # TESTS FOR INVALID PARAMETERS
      
      # Test the behaviour when an invalid parameter is passed to the
      # String backend. Expected behaviour: TypeError exception is
      # raised.
      def test_invalid_parameter
        assert_raise TypeError do
          Backend::String.new(123)
        end
      end
      
      # Test the behaviour when an array of mixed elements is passed to
      # the String backend. Expected behaviour: InvalidArray is raised.
      def test_invalid_mixed
        assert_raise Backend::String::InvalidArray do
          Backend::String.new([1, 3, "foo"])
        end
      end
      
      # Test the behaviour when an array of integers with values out of
      # the byte range is passed to the String backend. Expected
      # behaviour: InvalidArray is raised.
      def test_invalid_outofrange
        assert_raise Backend::String::InvalidArray do
          Backend::String.new([1, 3, -1, 256])
        end
      end
    end

    # Test the String backend providing an actual String instance
    class WithString < self
      def setup
        super
        open @file_content
      end
    end

    # Test the String backend providing an Array instance
    class WithArray < self
      def setup
        super
        open @file_content.split(//).collect { |el| el[0] }
      end
    end

    # TODO: test more Array-like classes with this backend

  end
end

# Local Variables:
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End:
