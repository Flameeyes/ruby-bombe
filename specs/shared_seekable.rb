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

# Description for non-seekable backends classes
#
# This shared example tests the opposite of 'all seekable backends'
# and make sure that non-seekable backends are really handled like
# those.
describe 'all non-seekable backends', :shared => true do
  it "should not have the seek_ internal method" do
    @klass.instance_methods.should_not include("seek_")
  end

  it "should not have the tell_ internal method" do
    @klass.instance_methods.should_not include("seek_")
  end
end

# Description for non-seekable backends instances
#
# Even though we check that the class does not add the internal
# instance methods for seek and tell, we want to make sure that all
# the instances do _not_ declare themselves as responding to the seek
# and tell methods.
describe 'all non-seekable instances', :shared => true do
  it 'should not respond to seek' do
    @backend.should_not respond_to :seek
  end

  it 'should not respond to tell' do
    @backend.should_not respond_to :tell
  end
end

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
  # Even though we already checked that the class for these have the
  # internal methods, make sure they declare themselves as responding
  # to the seek and tell methods.
  it "should respond to seek" do
    @backend.should respond_to :seek
  end

  it "should respond to tell" do
    @backend.should respond_to :tell
  end

  it "should report zero at the first position query" do
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

  # Test negative absolute seeks (they have to throw InvalidSeek) For
  # extra safety, try first a borderline value, then a bigger one.
  it "should reject negative absolute seeks (border)" do
    lambda do
      @backend.seek(-1)
    end.should(raise_error(Bombe::InvalidSeek) do |e|
                 e.amount.should == -1
                 e.whence.should == ::IO::SEEK_SET
                 e.pos.should be_nil
               end)
  end

  it "should reject negative absolute seeks" do
    lambda do
      @backend.seek(-100)
    end.should(raise_error(Bombe::InvalidSeek) do |e|
                 e.amount.should == -100
                 e.whence.should == ::IO::SEEK_SET
                 e.pos.should be_nil
               end)
  end

  # Test relative seeks that would move before the start of
  # data. Again, check first a border value, then a bigger value.
  it "should reject relative seeks before start of data (border)" do
    # First position ourselves at the middle of the file
    @backend.seek(512)

    lambda do
      @backend.seek(-513, ::IO::SEEK_CUR)
    end.should(raise_error(Bombe::InvalidSeek) do |e|
                 e.amount.should == -513
                 e.whence.should == ::IO::SEEK_CUR
                 e.pos.should == 512 # where we seeked
               end)
  end

  it "should reject relative seeks before start of data" do
    # First position ourselves at the middle of the file
    @backend.seek(512)

    lambda do
      @backend.seek(-1000, ::IO::SEEK_CUR)
    end.should(raise_error(Bombe::InvalidSeek) do |e|
                 e.amount.should == -1000
                 e.whence.should == ::IO::SEEK_CUR
                 e.pos.should == 512 # where we seeked
               end)
  end

  # Test the behaviour of the seek and tell methods for seeks with
  # no movement.
  #
  # Since no movements at all (a relative seek of zero bytes, or an
  # absolute seek to the same position) might be special cases for
  # some backends, especially if seek is emulated, test these cases
  # explicitly.
  it "should allow relative seeks of zero amount" do
    @backend.seek(512)
    @backend.seek(0, ::IO::SEEK_CUR)
    @backend.tell.should == 512
  end

  it "should allow absolute seek to the same position (tell)" do
    @backend.seek(512)
    @backend.seek(@backend.tell)
    @backend.tell.should == 512
  end

  it "should allow absolute seek to the same position (known)" do
    @backend.seek(512)
    @backend.seek(512)
    @backend.tell.should == 512
  end

  it "should reject absolute seeks over the end of data (border)" do
    pending
  end

  it "should reject absolute seeks over the end of data" do
    pending
  end

  it "should reject relative seeks over the end of data (beginning, borer)" do
    pending
  end

  it "should reject relative seeks over the end of data (beginning)" do
    pending
  end

  it "should reject relative seeks over the end of data (middle, border)" do
    pending
  end

  it "should reject relative seeks over the end of data (middle)" do
    pending
  end

  # Test invalid parameters to the seek method
  it "should reject seeks with invalid amounts (String)" do
    lambda do
      @backend.seek("foo")
    end.should raise_error(TypeError)
  end

  it "should reject seeks with invalid amounts (Float)" do
    lambda do
      @backend.seek(0.1)
    end.should raise_error(TypeError)
  end

  it "should reject seeks with invalid whences (String)" do
    lambda do
      @backend.seek(0, "bar")
    end.should raise_error(Bombe::InvalidWhence)
  end

  it "should reject seeks with invalid whences (out of range number)" do
    lambda do
      @backend.seek(0, 123)
    end.should raise_error(Bombe::InvalidWhence)
  end

end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
