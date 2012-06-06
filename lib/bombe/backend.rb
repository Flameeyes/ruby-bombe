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

# Even though we're not going to use this code directly, we require
# this to have the TruncatedDataError exception since we want to
# follow the standard Ruby library in term of exceptions raised as
# much as we can.
require 'readbytes'

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
        # data or after the end of it .
        raise InvalidSeek.new(amount, whence, tell) if
          newpos < 0 or ( respond_to? :size and newpos >= size )

        # Finally time to call the implementation. But since the
        # implementation might raise an InvalidSeek exception (when
        # going over the end of file for backends not providing a size
        # method), we need to restore the old position in that case to
        # ensure we didn't move... yes it might be slow.
        begin
          oldpos = tell
          seek_(amount, whence)
        rescue InvalidSeek
          # we hope not to create a recursive call here
          seek(oldpos)

          raise
        end

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

      # Implement a read functions for the backends
      #
      # This maps directly to most common read methods from IO and
      # other objects, but it ensures, if possible, that the size read
      # does not go over the end of the file.
      #
      # Note that the safety in here is not available if the backend
      # does not support the size function, in those cases the backend
      # should take care of it by itself.
      #
      # Note that this function does not check for the presence of the
      # read_ method since it is supposed to _always_ be there (you
      # won't have a backend unable to read data from!).
      def read(n)
        n = [n, size-tell].min if
          respond_to? :size and respond_to? :tell

        read_(n)
      end

      # Implement an interface similar to the one offered by
      # readbytes.rb from Ruby standard library itself.
      #
      # Unfortunately they didn't make the readbytes interface generic
      # enough, which means I actually have to reimplement it here.
      def readbytes(n)
        # read at most n bytes...
        str = read(n)

        # if we're already at the end of the file and nothing could be read.
        # this should be checked since we shouldn't need this...
        raise EOFError, "End of file reached" if str == nil

        # If the string is shorter than we requested, it was
        # truncated, raise an exception.
        raise TruncatedDataError.new("data truncated", str) if str.size < n

        str
      end

      # Okay now we need to inject our own little respond_to? method
      # that can tell us whether the children classes actually respond
      # to the given method...

      WrappedMethods = [ :seek, :tell, :size ]

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
