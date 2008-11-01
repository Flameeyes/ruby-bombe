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

# Generic description for all the String instances.
describe 'all Backend::Socket instances', :shared => true do
  it_should_behave_liek 'all Backend::IO instances'

  it 'should be a Socket backend' do
    @backend.should be_possibly_kind_of(Bombe::Backend::Socket)
  end
end

# Describe the functionality of the backend
describe Bombe::Backend::Socket do
  it_should_behave_like "all backends"

  # All the socket test requires a socket where to connect; for this
  # reason start here a thread with a TCP server to use for reading
  # data from.
  #
  # TODO: not all the tests have to act on client socket, some should
  # use server sockets.
  # TODO: UDP sockets should also be tested
  before(:all) do
    # Pick a random port over the 10240 range; TCPServer and
    # TCPSocket expect it to be a string, so convert it.
    @port = (10240 + rand(1024)).to_s

    # Create a new Thread for the TCP server
    @thread = Thread.new do
      begin
        serv = TCPServer.new(@port)

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

  describe "class" do

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
      instance.close
    end

    it 'should reject not opened sockets' do
      sock = ::Socket.new(::Socket::Constants::AF_INET,
                          ::Socket::Constants::SOCK_STREAM,
                          0)

      lambda do
        Bombe::Backend::Socket.new(sock)
      end.should (raise_error(Exception) do |e|
        # since raise_error does not accept specific Exception
        # objects, check afterward that the correct exception is
        # raised.
        e.should == Bombe::ClosedStreamError
      end)
    end

    it "should accept a TCPSocket parameter" do
      instance = Bombe::Backend::Socket.
        new(::TCPSocket.new("localhost", @port))
      instance.should be
      instance.close
    end

    it "should reject a nil parameter" do
      lambda do
        Bombe::Backend::Socket.new(nil)
      end.should raise_error(TypeError)
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
