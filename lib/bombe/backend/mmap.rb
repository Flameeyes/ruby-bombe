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

# If it's available, require mmap, but don't fail if it's not present.
begin
  require 'mmap'
  require 'bombe/backend'

  module Bombe::Backend
    # Memory map backend
    #
    # This class implements a backend using the ruby-mmap extension to
    # map it into memory (through the mmap(2) syscall). Memory mapped
    # files can be shared among processes with very little resource
    # request.
    class Mmap < Base
      include CursorEmulation

      # Initialise the Mmap backend. Accept both an explicit memory
      # map or a filename; if the argument is not a memory map object,
      # assume it is meant to be used as filename.
      #
      # When creating a new memory map, map it private and read-only.
      def initialize(arg)
        if arg.possibly_kind_of? ::Mmap
          @mmap = arg
        else
          # When a file at the given path does not exist, or it is not
          # accessible, Mmap.new raises ArgumentError, but that makes
          # it impossible to discern the two cases, so check it first
          # with File class utility functions.
          #
          # Useful side-effect: we make sure that the argument can be
          # converted to String since File functions check that for
          # us.
          raise Bombe::NotFoundError.new(arg) unless ::File.exist?(arg)
          raise Bombe::PermissionError.new(arg) unless ::File.readable?(arg)

          @mmap = ::Mmap.new(arg, "r", ::Mmap::MAP_SHARED)
        end
      end

      protected

      # Close the memory map, this means removing the memory mapping.
      def close_
        @mmap.munmap
      end

    end
  end
rescue LoadError
  $BOMBE_NO_MMAP = true
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
