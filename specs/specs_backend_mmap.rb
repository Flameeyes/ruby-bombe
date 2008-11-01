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

require 'bombe/backend/mmap'

# if the mmap backend is missing, don't run the mmap specs test, since
# they would obviously fail.
unless $BOMBE_NO_MMAP
  # Generic description for all the Mmap instances.
  describe 'all Backend::Mmap instances', :shared => true do
    it_should_behave_like "all backend instances"
    it_should_behave_like "all file-backed backends"

    it "should be a Mmap backend" do
      @backend.class.ancestors.should include(Bombe::Backend::Mmap)
    end
  end

  # Describe the generic functionality of the Bombe::Backend::Mmap
  # class.
  describe Bombe::Backend::Mmap do
    describe "class" do
      before(:all) do
        @klass = Bombe::Backend::Mmap
      end

      it_should_behave_like "all file-backed backends"
      it_should_behave_like "all path-based backends"
      it_should_behave_like "all seekable backends"

      # Test the behaviour when an invalid parameter is passed to the Mmap
      # backend. Expected behaviour: TypeError exception is raised.
      it "should reject a Hash parameter" do
        lambda do
          Bombe::Backend::Mmap.new({})
        end.should raise_error(TypeError) do |e|
          e.message.should ==
            "wrong argument type Hash (expected Mmap, String, File)"
        end
      end
    end

    # Test the behaviour of the Mmap backend when providing an already
    # open Mmap instance.
    describe "with a Mmap instance parameter" do
      it_should_behave_like "all Backend::Mmap instances"

      before(:each) do
        @backend =
          Bombe::Backend::Mmap.new(Mmap.new(@tmpf.path,
                                            "r",
                                            Mmap::MAP_SHARED))
      end
    end

    # Test the behaviour of the Mmap backend when providing a file
    # path with a String instance.
    #
    # Instead of providing an already-mapped file, this time the
    # backend will havae to open the map itself.
    describe "with a String path parameter" do
      it_should_behave_like "all Backend::Mmap instances"

      before(:each) do
        @backend = Bombe::Backend::Mmap.new(@tmpf.path.to_s)
      end
    end

    # Test the behaviour of the Mmap backend when providing the file
    # path with a Pathname instance.
    #
    # Note that this should be redundant since the previous
    # description does basically the same, but it's here to ensure
    # that the backend does not expects path _only_ being given
    # through String instances.
    describe "with a Pathname path parameter" do
      it_should_behave_like "all Backend::Mmap instances"

      before(:each) do
        @backend = Bombe::Backend::Mmap.new(@tmpf.path)
      end
    end

  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
