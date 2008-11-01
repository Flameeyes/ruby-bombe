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

require 'bombe/backend/gzip'

# Create a shared case for backends acting on gzip-compressed files.
#
# While the Gzip backend is unique in this regard, it is useful to
# test the initialisation, which cannot use the file-backed
# description.
describe "all gzip-backed backends", :shared => true do
  # We cannot use the "all file-backed backends" description here
  # since our temporary file needs to be compressed with gzip.
  before(:all) do
    @tmpf = Tempfile.new(description)

    writer = ::Zlib::GzipWriter.new(@tmpf)
    writer.write @content
    writer.close

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

describe "all Backend::Gzip instances", :shared => true do
  it_should_behave_like "all backend instances"
  it_should_behave_like "all backends"
  it_should_behave_like "all gzip-backed backends"

  it "should be a Gzip backend" do
    @backend.class.ancestors.should include(Bombe::Backend::Gzip)
  end
end

# Describe the functionality of the Bombe::Backend::Gzip class
describe Bombe::Backend::Gzip do
  describe "initialisation" do
    before(:all) do
      @klass = Bombe::Backend::Gzip
    end

    it_should_behave_like "all gzip-backed backends"
    it_should_behave_like "all path-based backends"

    # Test the behaviour when an invalid parameter is passed to the
    # backend. Expected behaviour: TypeError exception is raised.
    it "should not accept a Hash parameter" do
      lambda do
        Bombe::Backend::Gzip.new({})
      end.should raise_error(TypeError) do |e|
        e.message.should ==
          "wrong argument type Hash (expected Mmap, String, File)"
      end
    end

    # Test the behaviour when the path to a non-compressed file is
    # passed to the backend. Expected behaviour: a
    # Zlib::GzipFile::Error ("not in gzip format") exception is
    # raised.
    it "should fail to open non-compressed files" do
      # Create a non-compressed temporary file with the usual
      # content...
      temp = Tempfile.new(description + "noncompressed")
      temp.write(@content)
      temp.close

      lambda do
        Bombe::Backend::Gzip.new(temp.path)
      end.should raise_error(Zlib::GzipFile::Error) do |e|
        e.message.should == "not in gzip format"
      end

      # Make sure the temporary file is deleted
      temp.unlink
    end
  end

  # Test the behaviour of the backend when providing an already open
  # GzipReader
  describe "with a GzipReader parameter" do
    it_should_behave_like "all Backend::Gzip instances"

    before(:each) do
      @tmpf.open
      @backend = Bombe::Backend::Gzip.new(::Zlib::GzipReader.new(@tmpf))
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
