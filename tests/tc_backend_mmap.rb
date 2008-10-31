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
      # Open the backend, this is called by the sub-classes that
      # actually implement tests
      def open(arg)
        @backend = Backend::Mmap.new(arg)
      end

      # Specialise the class test, the backend instance is going to be
      # Backend::Mmap as well as Backend::Base.
      def test_class
        super
        
        assert_kind_of Backend::Mmap, @backend
      end

      class Standalone < Test::Unit::TestCase
        # Test the behaviour when an invalid parameter is passed to the Mmap
        # backend. Expected behaviour: TypeError exception is raised.
        def test_invalid_parameter
          assert_raise TypeError do
            Backend::Mmap.new({})
          end
        end
      end

      # Test the behaviour of the Mmap backend when passing it a
      # direct Mmap instance.
      class WithMmap < self
        def setup
          super
          open(::Mmap.new(file_path, "r", ::Mmap::MAP_SHARED))
        end
      end
      
      # Test the behaviour of the Mmap backend when passing it a
      # String with the path of a new file to map in memory.
      class WithPathString < self
        def setup
          super
          open(file_path.to_s)
        end
      end
      
      # Test the behaviour of the Mmap backend when passing it a
      # Pathname with the path of a new file to map in memory.
      #
      # Note that this should be redundant since WithPathString does
      # basically the same, but it's here to ensure that the backend
      # does not expects path _only_ being given through String
      # instances.
      class WithPathname < self
        def setup
          super
          open(file_path)
        end
      end
      
    end
  end
end
