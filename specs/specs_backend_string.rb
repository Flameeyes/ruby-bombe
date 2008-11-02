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

require 'bombe/backend/string'

# Generic description for all the String instances.
describe 'all Backend::String instances', :shared => true do
  it_should_behave_like 'all backends'
  it_should_behave_like 'all backend instances'
  it_should_behave_like 'all seekable instances'

  it "should be a String backend" do
    @backend.should be_possibly_kind_of(Bombe::Backend::String)
  end
end

describe Bombe::Backend::String do

  # Test some of the possibilities for initialising a string
  # backend. Test initialisation with different type of strings,
  # arrays, both valid and invalid, to make sure that the correct
  # parameters are accepted and the wrong parameters are rejected.
  describe "class" do
     before(:all) do
      @klass = Bombe::Backend::String
    end

    # We use convenience functions here, since otherwise all the tests
    # would repeat the same exact code.  Have one for valid parameters
    # and one for invalid arrays (invalid parameters get a different
    # one, and the same for all cases).

    def check_valid_parameter(arg)
      backend = Bombe::Backend::String.new(arg)
      backend.should be
      backend.close
    end

    it "should accept a String parameter" do
      check_valid_parameter("string")
    end

    it "should accept a valid Array parameter" do
      check_valid_parameter([0, 1, 2, 3, 4, 5])
    end

    it "should accept complex String parameters" do
      check_valid_parameter("\0foobar\255\255\255\0\0\0")
    end

    it "should reject integer parameters" do
      lambda do
        backend = Bombe::Backend::String.new(123)
      end.should raise_error(TypeError)
    end

    def check_invalid_array(arg)
      lambda do
        backend = Bombe::Backend::String.new(arg)
      end.should(raise_error(Exception) do |e|
                   e.should == Bombe::Backend::String::InvalidArrayError
                 end)
    end

    it "should reject mixed Array parameters" do
      check_invalid_array([1, 3, "foo"])
    end

    # check specifically in presence of 256 (the lowest invalid
    # positive out of range value).
    it "should reject out-of-range (positive, border) parameters" do
      check_invalid_array([1, 3, 3, 4, 256])
    end

    it "should reject out-of-range (positive) parameters" do
      check_invalid_array([1, 3, 3, 4, 300])
    end

    # check specifically in presence of -1 (the highest invalid
    # negative out of range value).
    it "should reject out-of-range (negative, border) parameters" do
      check_invalid_array([1, 3, 3, 4, -1])
    end

    it "should reject out-of-range (negative) parameters" do
      check_invalid_array([1, 3, 3, 4, -200])
    end
  end

  describe "with a String parameter" do
    it_should_behave_like "all Backend::String instances"

    before(:each) do
      @backend = Bombe::Backend::String.new(@content)
    end
  end

  describe "with a valid Array parameter" do
    it_should_behave_like "all Backend::String instances"

    before(:each) do
      @backend = Bombe::Backend::String.new @content.split(//).collect {
        |el| el[0] }
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
