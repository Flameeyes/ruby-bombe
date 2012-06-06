# -*- coding: utf-8 -*-
# This file is part of ruby-bombe
# Copyright 2008 Diego "Flameeyes" Pettenò <flameeyes@gmail.com>
#
# ruby-bombe is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# ruby-bombe is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with ruby-bombe.  If not, see
# <http://www.gnu.org/licenses/>.

require 'bombe/backend'
require 'bombe/cursoremulation'
require 'bombe/utils'

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
    InvalidArrayError =
      Exception.new("The given array is not an array of bytes.")

    # Initialise the String backend with the provided string or array.
    # If an array is given, sanity check it.
    def initialize(arg)
      super()

      if Bombe::Utils::check_type(arg, [::Array, ::String]) == ::Array
        arg.each do |el|
          # all the elements have to be integers
          raise InvalidArrayError unless el.possibly_kind_of? Integer
          # no element can have a value of 256 or more
          raise InvalidArrayError if el > 255
          # no element can have a value of -1 or less
          raise InvalidArrayError if el < 0
        end
      end

      @array = arg
    end

    # Provide the size of the string or array
    def size_
      @array.size
    end

    # Provide a function to read data to the Base class.
    #
    # Since we implement the size method, we don't need to worry to
    # go over the end of data, Base#read takes care of that for us.
    def read_(n)
      val = @array[tell..(tell+n-1)]

      # if it's a string we return it right away
      return val if val.is_a? ::String

      # if it's not a string we have to make it one
      return val.collect { |x| x.chr }.to_s
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
