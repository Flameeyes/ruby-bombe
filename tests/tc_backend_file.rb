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

require 'bombe/backend_file'

module Bombe
  class TC_Backend_File < TT_Backend
    def setup
      super
      
      # TODO this has to be tested with both strings and pathnames
      @backend = Backend::File.new(file_path.to_s)
    end

    # Specialise the class test, the backend instance is going to be
    # Backend::File, Backend::IO and Backend::Base all at once.
    def test_class
      super
      
      assert_kind_of Backend::IO, @backend
      assert_kind_of Backend::File, @backend
    end

    # Test the behaviour when an invalid parameter is passed to the File
    # backend. Expected behaviour: TypeError exception is raised.
    def test_invalid
      assert_raise TypeError do
        Backend::File.new({})
      end
    end

  end
end
