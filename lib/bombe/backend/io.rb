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
require 'bombe/utils'

module Bombe
  module Backend
    # IO backend
    #
    # This class allow accessing data from IO instances, like files,
    # sockets, pipes, ...
    #
    # Most of this class is just a wrap around IO methods already
    class IO < Base
      def initialize(io)
        Utils::check_type(io, ::IO)

        # If the IO channel is closed or is at end of file, raise a
        # ClosedStreamError exception.
        #
        # Note: this is blocking with Socket arguments, so it might
        # have to be rewritten before it gets into production.
        raise Bombe::ClosedStreamError if io.closed? or io.eof?

        @io = io

        # Not all IO stream accept seek and tell, so before we
        # continue we have to ensure that they do. To do this, we test
        # the two calls and note down the missing ones.
        begin
          io.tell
          def self.tell_
            @io.tell
          end
        # even a tell request will produce an illegal pipe exception.
        rescue Errno::ESPIPE
        end

        begin
          io.seek(0)
          def self.seek_(amount, whence)
            @io.seek(amount, whence)
          end
        # even a tell request will produce an illegal pipe exception.
        rescue Errno::ESPIPE
        end

      end

      def close_
        @io.close
      end
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
