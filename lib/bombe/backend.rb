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

require 'bombe/exceptions'
require 'bombe/utils'

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
        raise NoMethodError.new("internal interface missing", "seek") unless
          respond_to? "seek_"

        # only accept integer amounts for seeking, check this first,
        # so that the backends can ignore it.
        Utils::check_type(amount, Integer)

        case whence
        when ::IO::SEEK_SET
          # make sure it does not try to seek to a negative position
          raise InvalidSeek.new(amount, whence) unless amount >= 0
        when ::IO::SEEK_CUR
          # make sure it does not try to seek to a negative position
          raise InvalidSeek.new(amount, whence, tell) unless amount+tell >= 0
        when ::IO::SEEK_END
          # Don't allow negative seeks if there is no way to know the
          # total size of the stream (compressed files, pipes, ...)
          raise InvalidSeek.new(nil, whence) unless respond_to? "size_"
          # make sure it does not try to seek to a negative position
          raise InvalidSeek.new(amount, whence) unless amount+size >= 0
        else
          # raise an exception if the whence parameter is unknown
          raise InvalidWhence.new(whence)
        end

        # finally call the implementation of this
        seek_(amount, whence)

        # Always return 0
        0
      end

      # Return the current position in the data.
      #
      # This function will give the position of the reading cursor in
      # the data, starting from 0 that is the start of the data.
      def tell
        raise NoMethodError.new("internal interface missing", "tell") unless
          respond_to? "tell_"

        tell_
      end

      # Close the element and cleanup its resources.
      #
      # This function allows to free the resources used by the backend
      # (file descriptors, memory maps, temporary files, ...).
      #
      # Since all the backends should be closed after use is
      # terminated, this function cannot raise exceptions for missing
      # implementations; on the other hand, backends might not require
      # any task after use, so allow the internal close_ method to be
      # missing.
      #
      # Also, some backends allow recursive destruction for the
      # arguments they are passed; for instance a Gzip backend
      # instance might wish to recursively close the GzipReader
      # instance it was given at opening, so add an optional recursive
      # parameter that allows for requesting recursive closing.
      #
      # Some backends might allow users to pass parameters from which
      # to build their internal data access, in which case they'd also
      # have to close it even if the user doesn't ask them to, so
      # allow a @force_recursive_close variable to be set to true, to
      # force closing.
      def close(recursive = false)
        if not respond_to? :close_
          return
        elsif method(:close_).arity == 1
          close_(recursive or @force_recursive_close)
        else
          close_
        end
      end

      # To be consistent with other Ruby standard classes, provide a
      # close! method that always requests recursive closing of the
      # backend.
      def close!
        close(true)
      end

      # Okay now we need to inject our own little respond_to? method
      # that can tell us whether the children classes actually respond
      # to the given method...

      WrappedMethods = [ :seek, :tell, :read, :readbytes ]

      def respond_to?(method)
        return super(method) unless WrappedMethods.include? method

        return super(method.to_s + "_")
      end
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
