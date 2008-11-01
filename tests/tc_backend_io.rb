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

module Bombe
  class TC_Backend_IO < TT_Backend
    # Open the backend, this is called by the sub-classes that
    # actually implement tests
    def open(arg)
      @backend = Backend::IO.new(arg)
    end

    # Specialise the class test, the backend instance is going to be
    # both Backend::IO and Backend::Base.
    def test_class
      super
      
      assert_kind_of Backend::IO, @backend
    end

    class Standalone < Test::Unit::TestCase
      # Test the behaviour when an invalid parameter is passed to the IO
      # backend. Expected behaviour: TypeError exception is raised.
      def test_invalid_parameter
        assert_raise TypeError do
          Backend::IO.new("path")
        end
      end
    end

    # Test the IO backend providing a File instance as argument
    class WithFile < self
      def setup
        super
        open File.new(file_path)
      end
    end

    # Test the IO backend providing a Tempfile instance as argument
    #
    # This will make sure that even delegated types of IO are accepted
    # as they were real IO.
    class WithTempfile < self
      def setup
        super
        @tmpf.open
        open @tmpf
      end
    end

  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
