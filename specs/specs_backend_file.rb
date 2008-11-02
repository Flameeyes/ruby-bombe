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

require 'bombe/backend/file'

# Generic description for all the File instances.
describe 'all Backend::File instances', :shared => true do
  it_should_behave_like "all file-backed backends"
  it_should_behave_like "all Backend::IO instances"
  it_should_behave_like 'all seekable instances'

  it "should be a File backend" do
    @backend.should be_possibly_kind_of(Bombe::Backend::File)
  end
end

# Describe the generic functionality of the Bombe::Backend::File
# class.
describe Bombe::Backend::File do
  describe "class" do
    before(:all) do
      @klass = Bombe::Backend::File
    end

    it_should_behave_like "all file-backed backends"
    it_should_behave_like "all path-based backends"

    # Test the behaviour when an invalid parameter is passed to the File
    # backend. Expected behaviour: TypeError exception is raised.
    it "should reject a Hash parameter" do
      lambda do
        Bombe::Backend::File.new({})
      end.should(raise_error(TypeError) do |e|
                   # this is not raised by Bombe itself, but rather
                   # by File.new when its argument cannot be
                   # converted into a string (so it's not a valid
                   # path).
                   e.message.should ==
                     "can't convert Hash into String"
                 end)
    end
  end

  # Test the behaviour of the File backend when providing the file
  # path with a String instance.
  describe "with a String path parameter" do
    it_should_behave_like "all Backend::File instances"

    before(:each) do
      @backend = Bombe::Backend::File.new(@tmpf.path.to_s)
    end
  end

  # Test the behaviour of the File backend when providing the file
  # path with a Pathname instance.
  #
  # Note that this should be redundant since the previous description
  # does basically the same, but it's here to ensure that the backend
  # does not expects path _only_ being given through String instances.
  describe "with a Pathname path parameter" do
    it_should_behave_like "all Backend::File instances"

    before(:each) do
      @backend = Bombe::Backend::File.new(@tmpf.path)
    end
  end

  # TODO: file backend should also accept file instances and Tempfiles!
  # describe "with a Tempfile parameter" do
  #   it_should_behave_like "all Backend::File instances"
  #
  #   before(:each) do
  #     @tmpf.open
  #     @backend = Bombe::Backend::File.new(@tmpf)
  #   end
  # end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
