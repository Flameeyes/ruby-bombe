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

require 'bombe/backend/io'
require 'bombe/utils'
require 'socket'

module Bombe::Backend
  # Socket backend
  #
  # This class is a specialised IO backend that allows for reading
  # data out of a Socket instance. The Socket case is a special case
  # since it does not allow seeking in any way.
  class Socket < IO
    # Create a Socket backend instance
    #
    # This should allow a Socket instance to be passed as parameter.
    # TODO: it should allow for an Hash to be passed with :host, :port
    # and :protocol parameters to open a new Socket instance.
    def initialize(arg)
      # Since Socket and TCPSocket are implemented in a binary
      # extension, they are not parent and child here, so they have to
      # be listed separately; nonetheless, they are both IO instances,
      # which is good for us. To add support for UDP or other sockets,
      # add them to the array here.
      Bombe::Utils::check_type(arg, [::Socket, ::TCPSocket])

      super(arg)
    end

    # Since we cannot seek, remove the seek and tell methods so that
    # they can't be accessed. Note that we remove the _internal_
    # methods, not the public methods from Base!
    undef_method :seek_
    undef_method :tell_
  end
end

# Local Variables:
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End: