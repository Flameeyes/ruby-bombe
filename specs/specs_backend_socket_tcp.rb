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

describe "Bombe::Backend::Socket (TCP)" do
  it_should_behave_like "all backends"
  # All the socket test requires a socket where to connect; for this
  # reason start here a thread with a TCP server to use for reading
  # data from.
  #
  # TODO: not all the tests have to act on client socket, some should
  # use server sockets.
  before(:all) do
    # Pick a random port over the 10240 range; TCPServer and
    # TCPSocket expect it to be a string, so convert it.
    @port = (10240 + rand(1024)).to_s

    # Create a new Thread for the TCP server
    @thread = Thread.new do
      begin
        serv = TCPServer.new("localhost", @port)

        # accept as many sockets as requests
        while sock = serv.accept do
          # dump the random data for the test on it
          sock.write @content
          # and then close it
          sock.close
        end
      rescue Exception => e
        $stderr.puts e.message
      ensure
        # Make sure the server is closed when the thread is killed
        # (and it will be!)
        serv.close
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
                          ::Socket::Constants::SOCK_STREAM,
                          0)
      sock.connect(::Socket.sockaddr_in(@port, "localhost"))

      instance = Bombe::Backend::Socket.new(sock)
      instance.should be
      instance.close!
    end

    it "should accept a TCPSocket parameter" do
      instance = Bombe::Backend::Socket.
        new(::TCPSocket.new("localhost", @port))
      instance.should be
      instance.close!
    end
  end

  # make sure that the socket works and behave properly when using
  # TCPSocket objects. Socket and TCPSocket objects don't share the
  # same classes, so it's important to test both.
  describe "with a TCPSocket client" do
    it_should_behave_like "all Backend::Socket instances"
    it_should_behave_like "all Backend::IO instances with opt-out close"

    before(:each) do
      @io = ::TCPSocket.new("localhost", @port)
      @backend = Bombe::Backend::Socket.new(@io)
    end
  end

  # make sure that the socket works and behave properly when using
  # Socket objects. Socket and TCPSocket objects don't share the same
  # classes, so it's important to test both.
  describe "with a Socket client" do
    it_should_behave_like "all Backend::Socket instances"
    it_should_behave_like "all Backend::IO instances with opt-out close"

    before(:each) do
      @io = ::Socket.new(::Socket::Constants::AF_INET,
                          ::Socket::Constants::SOCK_STREAM,
                          0)
      @io.connect(::Socket.sockaddr_in(@port, "localhost"))

      @backend = Bombe::Backend::Socket.new(@io)
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
