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

require 'bombe/backend/socket'

module Bombe
  class TC_Backend_Socket < TT_Backend
    # Open the backend, this is called by the sub-classes that
    # actually implement tests
    def open(arg)
      @backend = Backend::Socket.new(arg)
    end

    # Specialise the class test, the backend instance is going to be
    # Backend::Socket, Backend::IO and Backend::Base all at once.
    def test_class
      super

      assert_kind_of Backend::IO, @backend
      assert_kind_of Backend::Socket, @backend
    end

    class Standalone < Test::Unit::TestCase
      # Test the behaviour when an invalid parameter is passed to the File
      # backend. Expected behaviour: TypeError exception is raised.
      def test_invalid_parameter
        assert_raise TypeError do
          Backend::Socket.new("socket")
        end
      end
    end

    # Test the behaviour of the Socket backend when providing a
    # TCPSocket instance.
    #
    # This class creates a new Thread with a TCPServer on it to allow
    # reading data out of it.
    class WithTCPSocketClient < self
      def setup
        super

        # Pick a random port over the 10240 range; TCPServer and
        # TCPSocket expect it to be a string, so convert it.
        port = (10240 + rand(1024)).to_s

        # Create a new Thread for the TCP server
        @thread = Thread.new do
          begin
            serv = TCPServer.new(port)
            # accept a single socket ...
            sock = serv.accept
            # ... and dump to it the file content ...
            sock.write(@file_content)
            # ... then close it
            sock.close
          ensure
            # Make sure the server is closed when the thread is killed
            # (and it will be!)
            serv.close
          end
        end

        open(TCPSocket.new("localhost", port))
      end

      # Cleanup the test; other than doing the usual teardown
      # procedure, we have to kill the spawned thread and close up the
      # server socket.
      def teardown
        super

        @thread.kill
      end
    end

    # TODO: test with TCP server, UDP client and server, and Unix
    # sockets!
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
