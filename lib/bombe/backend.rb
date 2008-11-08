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
     def initialize
        @teardown_always = []
        @teardown_recursive = []
     end

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

        newpos = case whence
                 when ::IO::SEEK_SET: amount
                 when ::IO::SEEK_CUR: tell + amount
                 when ::IO::SEEK_END
                   # Don't allow reverse seek if there is no way to
                   # know the total size of the stream (compressed
                   # files, pipes, ...)
                   raise InvalidSeek.new(nil, whence) unless respond_to? "size_"
                   size + amount
                 else
                   # raise an exception if the whence parameter is unknown
                   raise InvalidWhence.new(whence)
                 end

        # Raise an exception if trying to seek before the start of the
        # data or after the end of it . Note that we allow to position
        # at the very end of the data (EOF) but then it won't be
        # possible to do much more.
        raise InvalidSeek.new(amount, whence, tell) if
          newpos < 0 or ( respond_to? :size and newpos > size )

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
      # To simplify the logic, instead of creating a close_ internal
      # method for all the subclasses, this method will invoke the
      # method in two arrays: @teardown_always and
      # @teardown_recursive.  The subclasses can add during initialize
      # the Method objects for their teardown actions to those.
      #
      # TODO: if the methods are themselves allowing a recursive
      # parameter, it might be a good idea to call it.
      def close(recursive = false)

        # prepare a new array with the two arrays merged if going for
        # recursive close.
        methods = [ @teardown_always,
                    recursive ? @teardown_recursive : []
                  ].flatten

        # Call each method; this means that the methods should not be
        # dependent one from the other; if they are a new method
        # should be created and added to the array intead.
        methods.each do |method|
          method.call
        end
      end

      # To be consistent with other Ruby standard classes, provide a
      # close! method that always requests recursive closing of the
      # backend.
      def close!
        close(true)
      end

      # Report the size of the data present in the backend
      #
      # This method is used to tell the user how big the data is, like
      # the size of a file or of an array. Not all backends will be
      # able to tell this. For instance a Socket or a generic IO
      # backend won't be able to handle this.
      def size
        raise NoMethodError.new("internal interface missing", "size") unless
          respond_to? "size_"

        size_
      end

      # Okay now we need to inject our own little respond_to? method
      # that can tell us whether the children classes actually respond
      # to the given method...

      WrappedMethods = [ :seek, :tell, :size, :read, :readbytes ]

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
