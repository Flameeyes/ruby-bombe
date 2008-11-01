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

require 'bombe/backend/io'

# Generic description for all the IO instances.
#
# This is mostly empty right now since not all the IO backends tests
# will need file-backed access.
describe 'all Backend::IO instances', :shared => true do
  it_should_behave_like "all backend instances"

  it "should be an IO backend" do
    @backend.class.ancestors.should include(Bombe::Backend::IO)
  end
end

# Describe the generic functionality of the Bombe::Backend::IO class.
describe Bombe::Backend::IO do
  describe "initialisation" do
    it "should not accept a String parameter" do
      lambda do
        Bombe::Backend::IO.new("path")
      end.should raise_error(TypeError) do |e|
        e.message.should == "wrong argument type String (expected IO)"
      end
    end
  end

  describe "with a File parameter" do
    it_should_behave_like "all file-backed backends"
    it_should_behave_like "all Backend::IO instances"

    # For each test open a new file instance
    before(:each) do
      @backend = Bombe::Backend::IO.new(File.new(@tmpf.path))
    end
  end

  describe "with a Tempfile parameter" do
    it_should_behave_like "all file-backed backends"
    it_should_behave_like "all Backend::IO instances"
    
    # Reopen the @tmpf instance every time and use it as argument
    before(:each) do
      @tmpf.open
      @backend = Bombe::Backend::IO.new(@tmpf)
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End:
