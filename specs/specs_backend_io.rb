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

require 'bombe/backend/io'
require 'shared_template'
require 'shared_seekable'

# Generic description for all the IO instances.
#
# This is mostly empty right now since not all the IO backends tests
# will need file-backed access.
describe 'all Backend::IO instances', :shared => true do
  it_should_behave_like "all backend instances"

  it "should be an IO backend" do
    @backend.should be_possibly_kind_of(Bombe::Backend::IO)
  end
end

# Shared examples for handling of recursive close method
#
# These examples work on the basis that an IO backend might leave the
# IO stream it tethers to open after closing, if recursive close is
# not used.
describe "all Backend::IO instances with opt-out close", :shared => true do
  it "should leave the IO stream open after non-recursive closing" do
    # ensure the @io variable is defined.
    @io.should be

    # non-recursively close the backend, and set it to nil so that
    # after(:each) won't try to close it again
    @backend.close(false)
    @backend = nil

    @io.should_not be_closed

    # Close it afterward since we don't want to leak it
    @io.close
  end

  it "should not leave the IO stream open after recursive closing" do
    # ensure the @io variable is defined.
    @io.should be

    # recursively close the backend, and set it to nil so that
    # after(:each) won't try to close it again
    @backend.close(true)
    @backend = nil

    @io.should be_closed
  end
end

# Describe the generic functionality of the Bombe::Backend::IO class.
describe Bombe::Backend::IO do
  describe "class" do
    it "should reject a String parameter" do
      lambda do
        Bombe::Backend::IO.new("path")
      end.should(raise_error(TypeError) do |e|
                   e.message.should ==
                     "wrong argument type String (expected IO)"
                 end)
    end
  end

  describe "with a File parameter" do
    it_should_behave_like "all file-backed backends"
    it_should_behave_like "all Backend::IO instances"
    it_should_behave_like 'all seekable instances'
    it_should_behave_like "all Backend::IO instances with opt-out close"

    # For each test open a new file instance
    before(:each) do
      @io = File.new(@tmpf.path)
      @backend = Bombe::Backend::IO.new(@io)
    end
  end

  describe "with a Tempfile parameter" do
    it_should_behave_like "all file-backed backends"
    it_should_behave_like "all Backend::IO instances"
    it_should_behave_like 'all seekable instances'
    it_should_behave_like "all Backend::IO instances with opt-out close"

    # Reopen the @tmpf instance every time and use it as argument
    before(:each) do
      @tmpf.open
      @io = @tmpf
      @backend = Bombe::Backend::IO.new(@io)
    end
  end

  # Test the functioning of the code when using pipes instead (as the
  # basic IO type).
  #
  # This is a type of IO stream that has no seek and tell support, for
  # this reason it is important to test this as well as the cases
  # above that are backed by a file where seeking is allowed.
  describe "with pipes" do
    it_should_behave_like "all file-backed backends"
    it_should_behave_like "all Backend::IO instances"
    it_should_behave_like "all non-seekable instances"
    it_should_behave_like "all Backend::IO instances with opt-out close"

    before(:each) do
      # get a pipe pair
      @io, wr = ::IO.pipe

      # Dump all the content on the pipe, and close it; the reading
      # pipe will remain open until it's read completely.
      wr.write @content
      wr.close

      @backend = Bombe::Backend::IO.new(@io)
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
