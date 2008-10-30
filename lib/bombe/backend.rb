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

module Bombe
  module Backend

    # Base class for bombe's backends
    #
    # This is the fundament of the whole bombe backend system, all the
    # bombe backends derive from this class. This class defines the
    # interface of all the backends and takes care of throwing
    # NotImplementedError exceptions when a method is missing.
    #
    # Note: the primitive methods are all handled by this class, the
    # specific backends need to add a postfix underscore to their
    # implementations, and they need to make it private.
    class Base
      
      # Seek in the backend. This function will take care, among other
      # things, to check if the seek is valid, or if it would try to
      # get to a negative position, and if the whence is valid.
      def seek(amount, whence = ::IO::SEEK_SET)
        # if the backend does not implement seeking, throw an
        # exception
        raise NotImplementedError.new("seek not implemented") unless
          respond_to? "seek_"
        
        # only accept integer amounts for seeking, check this first,
        # so that the backends can ignore it.
        raise TypeError.new("wrong argument type #{amount.class} (expected Integer") unless
          amount.is_a? Integer

        case whence
        when ::IO::SEEK_SET
          # make sure it does not try to seek to a negative position
          raise InvalidSeek(amount, whence) unless amount >= 0
        when ::IO::SEEK_CUR
          # make sure it does not try to seek to a negative position
          raise InvalidSeek(amount, whence, tell) unless amount+tell >= 0
        when ::IO::SEEK_END
          # Don't allow negative seeks if there is no way to know the
          # total size of the stream (compressed files, pipes, ...)
          raise InvalidSeek(nil, whence) unless respond_to? "size_"
          # make sure it does not try to seek to a negative position
          raise InvalidSeek(amount, whence) unless amount+size >= 0
        else
          # raise an exception if the whence parameter is unknown
          raise InvalidWhence(whence)
        end

        # finally call the implementation of this
        seek_(amount, whence)

        # Always return 0
        0
      end

      def tell
        raise NotImplementedError.new("tell not implemented") unless
          respond_to? "tell_"

        tell_
      end

      def close
        raise NotImplementedError.new("close not implemented") unless
          respond_to? "close_"
      end
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End:
