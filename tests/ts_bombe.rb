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

require 'test/unit/ui/console/testrunner'
require 'test/unit/testsuite'
require 'pathname'

# Test templates
require Pathname.new(__FILE__).dirname + 'tt_backend'

require Pathname.new(__FILE__).dirname + 'tc_backend_io'

class Bombe::TestSuite
  def self.suite
    suite = Test::Unit::TestSuite.new("ruby-bombe testsuite")
    suite << Bombe::TC_Backend_IO.suite
  end
end

Test::Unit::UI::Console::TestRunner.run(Bombe::TestSuite)
