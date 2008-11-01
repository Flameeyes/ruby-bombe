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
  # Invalid seek exception; this exception is thrown when a seek is
  # requested that cannot be enacted, like:
  #
  # * absolute seek to negative value;
  # * relative seek that would move before the start of data;
  # * termination seek that would move before the start of data;
  # * termination seek on backends not supporting the size primitive.
  class InvalidSeek < Exception
    attr_reader :message, :amount, :whence, :pos
    def initialize(amount, whence, pos = nil)
      @amount = amount
      @whence = whence
      @pos = pos

      if amount
        @message = "Invalid seek #{amount} of whence #{whence}"
        @message += " (at #{pos})" if pos
      else
        # The only invalid seek with no amount is when the backend
        # does not support the size function.
        @message = "Invalid seek of whence #{whence}"
      end
    end
  end

  # Invalid whence exception; this exception is thrown when a seek is
  # requested with an invalid whence value.
  class InvalidWhence < Exception
    attr_reader :message, :whence
    def initialize(whence)
      @whence = whence
      @message = "Invalid whence #{whence} for seek"
    end
  end

  # Closed stream exception; this exception is thrown whenever a
  # backend is opened on an instance that is not open.
  ClosedStreamError = Exception.new("Closed stream or end of file")

  # Exception raised when the a file or other data source cannot be
  # found. This includes non-existent files on the local filesystem,
  # HTTP requests returning 404 errors and so on.
  #
  # This exception is used to replace other exceptions, like
  # Errno::ENOENT because not all backends throw the same exception,
  # or any exception at all, and the idea of bombe is that it provides
  # the same exact interface over different media.
  class NotFoundError < Exception
    attr_reader :path, :message
    def initialize(path)
      @path = path
      @message = "#{path} not found"
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
