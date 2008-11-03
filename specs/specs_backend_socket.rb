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
require 'specs_backend_io'

# Generic description for all the String instances.
describe 'all Backend::Socket instances', :shared => true do
  it_should_behave_like 'all Backend::IO instances'
  it_should_behave_like 'all non-seekable instances'

  it 'should be a Socket backend' do
    @backend.should be_possibly_kind_of(Bombe::Backend::Socket)
  end
end

# Describe the functionality of the backend, for non-protocol specific
# issues.
#
# This description only considers examples that are not specific to
# TCP or UDP, and thus don't need a server thread providing access to
# the data.
#
# Check specs_backend_socket_tcp.rb and specs_backend_socket_udp.rb
# for the protocol-specific descriptions.
describe Bombe::Backend::Socket do
  it_should_behave_like "all backends"

 describe "class" do
    before(:all) do
      @klass = Bombe::Backend::Socket
    end

    it 'should reject not opened sockets' do
      sock = ::Socket.new(::Socket::Constants::AF_INET,
                          ::Socket::Constants::SOCK_STREAM,
                          0)

      lambda do
        Bombe::Backend::Socket.new(sock)
      end.should(raise_error(Exception) do |e|
                   # since raise_error does not accept specific
                   # Exception objects, check afterward that the
                   # correct exception is raised.
                   e.should == Bombe::ClosedStreamError
                 end)
    end

    it "should reject a nil parameter" do
      lambda do
        Bombe::Backend::Socket.new(nil)
      end.should(raise_error(TypeError) do |e|
                   e.message.should ==
                     "wrong argument type NilClass (expected Socket, TCPSocket, UDPSocket)"
                 end)
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
