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
require 'zlib'

module Bombe::Backend
  # Gzip backend
  #
  # This class implements a backend that makes use of Ruby's
  # GzipReader class to access data compressed with gzip
  # compression.
  class Gzip < Base
    # Initialise the Gzip backend. Accept both an explicit GzipReader
    # class, an IO to link a new GzipReader instance to, or the path
    # to a file to open.
    #
    # If the argument is neither GzipReader nor IO, accept it as path
    # instead.
    def initialize(arg)
      if arg.is_a? ::Zlib::GzipReader
        @reader = arg
      elsif arg.is_a? ::IO
        @reader = ::Zlib::GzipReader.new(arg)
      else
        @reader = ::Zlib::GzipReader.new(::File.new(arg))
      end
    end

    def tell_
      @reader.tell
    end

    # Emulate seeking through a compressed file.  Since
    # gzip-compressed file don't really have a proper way to seek
    # through them, check whether one has to move forward or backward;
    # rewind if it has to move backward and discard as many bytes as
    # needed.
    #
    # TODO: seeking after the end of data is going to be a problem,
    # maybe it should be disallowed altogether.
    def seek_(amount, whence)
      # Calculate the new position.
      #
      # Warning: there is no SEEK_END seeking available on compressed
      # files!
      newpos = case whence
               when ::IO::SEEK_CUR: tell + amount
               when ::IO::SEEK_SET: amount
               end

      if newpos == tell # Nothing to do!
        return
      elsif newpos > tell
        # TODO: change this to readbytes!
        @reader.read(newpos-tell)
      else
        @reader.rewind
        @reader.read(newpos)
      end
    end

    def close_
      @reader.close
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End:
