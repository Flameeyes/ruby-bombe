# -*- coding: utf-8 -*-
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

task :default => [:spec]

begin
  require 'spec/rake/spectask'
  
  Spec::Rake::SpecTask.new do |t|
    t.libs << [ 'lib' ]
    t.spec_opts << "-f specdoc"
    t.spec_files = FileList['specs/shared_*.rb', 'specs/specs_*.rb']
    t.rcov = true
  end
rescue LoadError
  $stderr.puts "Unable to find rspec, spec testing won't be available"
end

# Local Variables:
# mode: ruby
# mode: flyspell-prog
# ispell-local-dictionary: "english"
# End:
