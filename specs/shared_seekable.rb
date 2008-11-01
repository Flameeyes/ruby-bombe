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

# Shared examples for seekable backends and instances.
#
# This code is split out of specs_template.rb since it's complex
# enough to stay on its own.

# Description for seekable backends classes.
#
# This shared example contain the tests to execute on the backends
# that support seeking (like File-backed backends).
describe "all seekable backends", :shared => true do
  it "should have the seek_ internal method" do
    @klass.instance_methods.should include("seek_")
  end

  it "should have the tell_ internal method" do
    @klass.instance_methods.should include("tell_")
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
