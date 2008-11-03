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

# Although the IO backends already import this, make sure the
# File#readbytes method is defined, since we're going to use it
# (outside of the backends) in the descriptions.
require 'readbytes'

# This is the shared description of all backends, that will hold the
# clauses that _have_ to be implemented by all the backends.
#
# Note that this description will not create the temporary file (since
# backends don't need to be file-backed), but does read 1KB of random
# data from /dev/urandom.
#
# TODO: make this not Linux-dependent by removing /dev/urandom usage.
describe "all backends", :shared => true do

  before(:all) do
    # Before anything, read 1KB of random data to use as example data
    File.open("/dev/urandom") do |randf|
      @content = randf.readbytes(1024)
    end
  end
end

# Describe backend instances separately from backends because we might
# want to test backends initialisation by themselves.
describe "all backend instances", :shared => true do
  # Close the backend after each test, since we don't want to test
  # compromised backends.
  after(:each) do
    # Since this may be called more than once, make sure we only cose
    # it once, by setting it to nil afterward. This also allows us for
    # making sure that each test starts from scratch.
    @backend.close! unless @backend.nil?
    @backend = nil
  end

  # Make sure that the backend is going to be an actual Bombe backend
  it "should be a backend" do
    @backend.should be_possibly_kind_of(Bombe::Backend::Base)
  end

  # All instances should answer to the close method
  it "should respond to the close method" do
    @backend.should respond_to(:close)
  end

  it "should respond to the close! method" do
    @backend.should respond_to(:close!)
  end
end

# We use Tempfile to write a temporary file with random data for each
# test, this file is created on the before(:all) so that all the tests
# can go on accessing it, and unlinked on after(:all).
require 'tempfile'

# Describe file-backed backends; this backend is used to test the
# behaviour of backends that use, at the end, a file on disk to read
# the data from.
#
# In addition to what the "all backends" case does, this also creates
# a temporary file where the 1KB data is written to.
describe "all file-backed backends", :shared => true do
  it_should_behave_like "all backends"

  before(:all) do
    # Use the description of the current case as filename; this should
    # not be a problem even if it includes spaces.
    @tmpf = Tempfile.new(description)
    @tmpf.write @content

    # close up the temporary file for now; this can be reopened by the
    # specific descriptions when they need it.
    @tmpf.close
  end

  after(:all) do
    # Once the test is done remove the temporary file altogether so
    # that it does not clutter the user's temporary directory.
    @tmpf.unlink
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
