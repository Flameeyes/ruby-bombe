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

module Bombe
  # Utility functions for the Bombe library; these allow writing
  # simpler code when the same repetitive task has to be done.
  module Utils

    # Ensure that the given object is of one of the given classes,
    # including delegate classses.
    #
    # If the object is not of one of the provided classes, not even
    # through delegation, raise a TypeError exception.
    def self.check_type(obj, klasses)
      # If only one type was given, make it an array to use the array
      # functions later.
      klasses = [klasses] if klasses.kind_of? Class

      # First off, check if the object is of one of the given classes,
      # if so, return true and all well.
      klasses.each do |klass|
        return klass if obj.kind_of? klass
      end

      # If we still got nothing, but the object responds to the
      # #__getobj__ method, check that one, it would be a delegated
      # class.
      return check_type(obj.__getobj__, klasses) if obj.respond_to? :__getobj__
      
      typenames = klasses.join(", ").chomp(", ")
      raise TypeError.new("wrong argument type #{obj.class} (expected #{typenames})")
    end
  end
end
