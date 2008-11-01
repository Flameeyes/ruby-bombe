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

        raise ClosedStream.new if io.closed?

        @io = io
      end

      def seek_(amount, whence)
        @io.seek(amount, whence)
      end

      def tell_
        @io.tell
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
