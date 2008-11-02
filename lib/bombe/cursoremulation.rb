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

require 'bombe/backend'

# Set of functions to emulate a cursor in a bombe backend.
#
# Bombe's interface allow sequential access with seek and tell
# functions to have some sort of random data access. Some backends,
# though, lack any support for sequential access, as they are designed
# for random data access, like arrays and strings.
#
# When you include this module, special seek and tell functions are
# added, that allow for emulation of seek and tell functions.
module Bombe::Backend::Base::CursorEmulation
  protected

  def tell_
    @pos = 0 unless @pos

    @pos
  end

  def seek_(amount, whence)
    @pos = 0 unless @pos

    case whence
    when ::IO::SEEK_SET
      @pos = amount
    when ::IO::SEEK_CUR
      @pos += amount
    when ::IO::SEEK_END
      raise Errno::EINVAL unless respond_to? :size
      @pos = size + amount
    end

    0
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
