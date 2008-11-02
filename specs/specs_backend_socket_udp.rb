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

require 'bombe/backend/socket'
require 'shared_template'
require 'shared_seekable'
require 'specs_backend_socket'

describe "Bombe::Backend::Socket (UDP)" do
  it_should_behave_like "all backends"
  # All the socket test requires a socket where to connect; for this
  # reason start here a thread with a UDP socket to use for reading
  # data from.
  before(:all) do
    @port = (10240 + rand(1024))

    # Create a new Thread for the UDP "server"
    @thread = Thread.new do
      loop do
        begin
          sock = UDPSocket.new
          sock.bind "localhost", @port
          sock.connect "localhost", @port+1

          # dump the random data for the test on it
          sock.write @content
          # and then close it
          sock.close
        rescue Exception => e
          $stderr.puts e.message
        end
      end
    end
  end

  after(:all) do
    @thread.kill
  end

  # Describe the behaviour of the class. While TCP sockets and UDP
  # sockets share the same backend class, this is tested on different
  # scenarios because they need to access the server thread.
  describe "class" do
    before(:all) do
      @klass = Bombe::Backend::Socket
    end

    # make sure that the Socket backend actually accepts Socket
    # instances. Note that the backend should reject closed sockets
    # and only accept open and valid sockets, this has to be
    # considered.
    it "should accept a Socket parameter" do
      sock = ::Socket.new(::Socket::Constants::AF_INET,
                          ::Socket::Constants::SOCK_DGRAM,
                          0)
      sock.bind(::Socket.sockaddr_in(@port+1, "localhost"))
      sock.connect(::Socket.sockaddr_in(@port, "localhost"))

      instance = Bombe::Backend::Socket.new(sock)
      instance.should be
      instance.close!
    end

    it "should accept a UDPSocket parameter" do
      sock = ::UDPSocket.new
      sock.bind("localhost", @port+1)
      sock.connect("localhost", @port)
      instance = Bombe::Backend::Socket.new(sock)
      instance.should be
      instance.close!
    end
  end

  # make sure that the socket works and behave properly when using
  # TCPSocket objects. Socket and TCPSocket objects don't share the
  # same classes, so it's important to test both.
  describe "with a UDPSocket parameter" do
    it_should_behave_like "all Backend::Socket instances"

    before(:each) do
      sock = ::UDPSocket.new
      sock.bind("localhost", @port+1)
      sock.connect("localhost", @port)
      @backend = Bombe::Backend::Socket.new(sock)
    end
  end

  # make sure that the socket works and behave properly when using
  # Socket objects. Socket and TCPSocket objects don't share the same
  # classes, so it's important to test both.
  describe "with a Socket parameter" do
    it_should_behave_like "all Backend::Socket instances"

    before(:each) do
      sock = ::Socket.new(::Socket::Constants::AF_INET,
                          ::Socket::Constants::SOCK_DGRAM,
                          0)
      sock.bind(::Socket.sockaddr_in(@port+1, "localhost"))
      sock.connect(::Socket.sockaddr_in(@port, "localhost"))

      @backend = Bombe::Backend::Socket.new(sock)
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
