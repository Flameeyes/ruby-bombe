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

require 'bombe/backend'

module Bombe::Backend
  # String backend
  #
  # This class implements a memory-hungry backend that simply access a
  # string. String-based (but also Array-based) acces allows for
  # reading files directly from memory, like files uncompressed
  # entirely into memory.
  #
  # Note that creating a backend instance of this backend through an
  # Array (rather than a String) requires a long time especially for
  # big arrays since all the elements are tested to ensure that it is
  # indeed an array of bytes, rather than an array of mixed integers
  # or anything like that.
  class String < Base
    include CursorEmulation

    # Exception thrown when the array is not a byte array (for
    # instance if it is a mixed type array or if it contains integers
    # > 255 or < 0.
    class InvalidArray < Exception
      def message
        "The given array is not an array of bytes."
      end
    end
    
    # Initialise the String backend with the provided string or array.
    # If an array is given, sanity check it.
    def initialize(arg)
      raise TypeError.new("wrong argument type #{arg.class} (expected Array or String)") unless
        arg.is_a? ::Array or arg.is_a? ::String
      
      if arg.is_a? ::Array
        arg.each do |el|
          # all the elements have to be integers
          raise InvalidArray unless el.is_a? Integer
          # no element can have a value of 256 or more
          raise InvalidArray if el > 255
          # no element can have a value of -1 or less
          raise InvalidArray if el < 0
        end
      end

      @array = arg
    end

    # Don't do anything, it's not needed
    def close_
    end

  end
end

# Local Variables:
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End:
