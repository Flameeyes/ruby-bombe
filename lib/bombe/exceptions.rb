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

module Bombe
  # Invalid seek exception; this exception is thrown when a seek is
  # requested that cannot be enacted, like:
  #
  # * absolute seek to negative value;
  # * relative seek that would move before the start of data;
  # * termination seek that would move before the start of data;
  # * termination seek on backends not supporting the size primitive.
  class InvalidSeek < Exception
    attr_reader :amount, :whence, :pos
    def initialize(amount, whence, pos = nil)
      @amount = amount
      @whence = whence
      @pos = pos

      if amount
        message = "Invalid seek #{amount} of whence #{whence}"
        message += " (at #{pos})" if pos
      else
        # The only invalid seek with no amount is when the backend
        # does not support the size function.
        message = "Invalid seek of whence #{whence}"
      end

      super(message)
    end
  end

  # Invalid whence exception; this exception is thrown when a seek is
  # requested with an invalid whence value.
  class InvalidWhence < Exception
    attr_reader :whence
    def initialize(whence)
      @whence = whence
      super("Invalid whence #{whence} for seek")
    end
  end

  # Closed stream exception; this exception is thrown whenever a
  # backend is opened on an instance that is not open.
  ClosedStreamError = Exception.new("Closed stream or end of file")

  # Simple class from which other path-based exception derive.
  #
  # This is just a convenience class used to have a path reader.
  class PathException < Exception
    attr_reader :path
    def initialize(path, msg)
      @path = path.to_s
      super(msg)
    end
  end

  # Exception raised when a file or other data source cannot be
  # found. This includes non-existent files on the local filesystem,
  # HTTP requests returning 404 errors and so on.
  #
  # This exception is used to replace other exceptions, like
  # Errno::ENOENT because not all backends throw the same exception,
  # or any exception at all, and the idea of bombe is that it provides
  # the same exact interface over different media.
  class NotFoundError < PathException
    def initialize(path)
      super(path, "#{path} not found")
    end
  end

  # Exception raised when the a file or other data source cannot be
  # accessed for permission problems (like a file for which the user
  # has no read permissions, or a 403 error returned by HTTP).
  #
  # This exception is used to replace other exceptions, like
  # Errno::ENOENT because not all backends throw the same exception,
  # or any exception at all, and the idea of bombe is that it provides
  # the same exact interface over different media.
  class PermissionError < PathException
    def initialize(path)
      super(path, "Permission denied accessing #{path}")
    end
  end

  # Exception raised when a path given for initialisation points to a
  # directory rather than a file.
  #
  # Since the backends only allow accessing files, it isn't valid to
  # give them a path for a directory instead.
  #
  # This exception is used to replace Errno::EISDIR, although that
  # might be just fine for what we need.
  # TODO: consider using Errno::EISDIR instead.
  class DirectoryError < PathException
    def initialize(path)
      super(path, "#{path} is a directory")
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
