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

require 'bombe/backend_mmap'

unless $BOMBE_NO_MMAP
  module Bombe
    class TC_Backend_Mmap < TT_Backend
      def setup
        super
        
        # TODO this has to be tested with strings and pathnames as well
        # as Mmap objects.
        @backend = Backend::Mmap.new(::Mmap.new(file_path, "r", ::Mmap::MAP_SHARED))
      end

      # Specialise the class test, the backend instance is going to be
      # Backend::Mmap as well as Backend::Base.
      def test_class
        super
        
        assert_kind_of Backend::Mmap, @backend
      end

      # Test the behaviour when an invalid parameter is passed to the Mmap
      # backend. Expected behaviour: TypeError exception is raised.
      def test_invalid
        assert_raise TypeError do
          Backend::Mmap.new({})
        end
      end

    end
  end
end
