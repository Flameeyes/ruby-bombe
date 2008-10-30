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

require 'bombe/backend_gzip'

module Bombe
  class TC_Backend_Gzip < TT_Backend
    def setup
      super
      
      # The TT_Backend#setup method has written 1KiB data
      # uncompressed, but we need to replace it with compressed data,
      # so re-open the temporary file, and create a GzipWriter over it.
      @tmpf.open

      writer = ::Zlib::GzipWriter.new(@tmpf)
      writer.write @file_content
      writer.close
      @tmpf.open

      # TODO this has to be tested with IO streams, and strings and
      # pathnames, too.
      @backend = Backend::Gzip.new(::Zlib::GzipReader.new(@tmpf))
    end

    # Specialise the class test, the backend instance is going to be
    # Backend::Gzip as well as Backend::Base.
    def test_class
      super
      
      assert_kind_of Backend::Gzip, @backend
    end

    # Test the behaviour when an invalid parameter is passed to the Gzip
    # backend. Expected behaviour: TypeError exception is raised.
    def test_invalid
      assert_raise TypeError do
        Backend::Gzip.new({})
      end
    end

  end
end

# Local Variables:
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End:
