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

# Shared examples for seekable backends and instances.
#
# This code is split out of specs_template.rb since it's complex
# enough to stay on its own.

# Description for seekable backends classes.
#
# This shared example contain the tests to execute on the backends
# that support seeking (like File-backed backends).
describe "all seekable backends", :shared => true do
  it "should have the seek_ internal method" do
    @klass.instance_methods.should include("seek_")
  end

  it "should have the tell_ internal method" do
    @klass.instance_methods.should include("tell_")
  end
end

# Description for seekable backends instances
#
# This shared example contains the tests to execute on the actual
# instances of seekable backends.
#
# We know that the data we use for test is at exactly 1KiB in
# size, so we can seek around up to that.
describe "all seekable instances", :shared => true do
  it "should report zero at the first query" do
    @backend.tell.should == 0
  end

  # Seek to the middle of the file and check that the reported
  # position is the one expected.
  it "should allow absolute seeking forward" do
    @backend.seek(512)
    @backend.tell.should == 512
  end

  it "should allow relative seeking forward" do
    @backend.seek(512, ::IO::SEEK_CUR)
    @backend.tell.should == 512
  end

  # Seek again to the middle of the file, then seek backward and check
  # that the position is the one expected.
  it "should allow absolute seeking backward" do
    @backend.seek(512)
    @backend.seek(384)
    @backend.tell.should == 384
  end

  it "should allow relative seeking backward" do
    @backend.seek(512)
    @backend.seek(-128, ::IO::SEEK_CUR)
    @backend.tell.should == 384
  end

  # Make sure that the seek always report zero as return value
  #
  # TODO: this maybe should be nil?
  it "should always report zero at seeking" do
    (@backend.seek(512)).should == 0
    (@backend.seek(128, ::IO::SEEK_CUR)).should == 0
    (@backend.seek(-256, ::IO::SEEK_CUR)).should == 0
  end

end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
