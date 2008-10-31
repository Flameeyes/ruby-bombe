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

module Bombe
  class TC_Backend_Gzip < TT_Backend

    # The TT_Backend#setup method has written 1KiB data uncompressed,
    # but we need to replace it with compressed data, so re-open the
    # temporary file, and create a GzipWriter over it.
    def setup
      super
      
      @tmpf.open

      writer = ::Zlib::GzipWriter.new(@tmpf)
      writer.write @file_content
      writer.close
    end

    # Open the backend, this is called by the sub-classes that
    # actually implement tests
    def open(arg)
      @backend = Backend::Gzip.new(arg)
    end

    # Specialise the class test, the backend instance is going to be
    # Backend::Gzip as well as Backend::Base.
    def test_class
      super
      
      assert_kind_of Backend::Gzip, @backend
    end

    class Standalone < Test::Unit::TestCase
      # Test the behaviour when an invalid parameter is passed to the
      # Gzip backend. Expected behaviour: TypeError exception is
      # raised.
      def test_invalid_parameter
        assert_raise TypeError do
          Backend::Gzip.new({})
        end
      end
    end

    # Test behaviour of the Gzip backend with a direct GzipReader
    # instance
    class WithReader < self
      def setup
        super
        @tmpf.open
        open ::Zlib::GzipReader.new(@tmpf)
      end
    end

    # Test behaviour of the Gzip backend with an IO instance
    # given. The backend should take care of opening the GzipReader
    # instance itself.
    class WithIO < self
      def setup
        super
        @tmpf.open
        open @tmpf
      end
    end

    # Test behaviour of the Gzip backend with a String instance with
    # the path to the file given. The backend should take care of
    # opening a File instance and then the GzipReader.
    class WithPathString < self
      def setup
        super
        open @file_path.to_s
      end
    end

    # Test behaviour of the Gzip backend with a Pathname instance with
    # the file given. The backend should take care of opening a File
    # instance and then the GzipReader.
    #
    # Note that this should be redundant since WithPathString does
    # basically the same, but it's here to ensure that the backend
    # does not expects path _only_ being given through String
    # instances.
    class WithPathname < self
      def setup
        super
        open @file_path
      end
    end

  end
end

# Local Variables:
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End:
