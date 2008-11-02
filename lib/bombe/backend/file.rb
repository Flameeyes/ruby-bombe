# -*- coding: utf-8 -*-
# This file is part of ruby-bombe
# Copyright 2008 Diego "Flameeyes" Pettenò <flameeyes@gmail.com>
#
# ruby-bombe is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# ruby-bombe is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with ruby-bombe.  If not, see
# <http://www.gnu.org/licenses/>.

require 'bombe/backend/io'
require 'pathname'

module Bombe
  module Backend
    # File backend
    #
    # This class is a very lightweight wrapper around Backend::IO: it
    # accepts a string or pathname as input, opens it and passes it to
    # the IO class.
    class File < IO
      def initialize(path)
        begin
          super(::File.new(path))

        # if the file does not exist or is not accessible, File.new
        # will throw some exceptions from the Errno module, but we
        # replace them with our own exceptions. Check the comments in
        # exceptions.rb for an explanation on why this is done.
        rescue Errno::ENOENT
          raise Bombe::NotFoundError.new(path)
        rescue Errno::EACCES
          raise Bombe::PermissionError.new(path)
        end
      end
    end
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
