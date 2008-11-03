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

# We need Pathname to get the name of the directory for the temporary
# file.
require 'pathname'

# Description for the backends that accept paths as parameters
#
# Most file-based backends will accept paths as parameters; check some
# possible variations here with String and Pathnames.
#
# Note: this does not behave like all file-backed backends since
# compressed files backends might require the file to be compressed
# before proceeding.
describe "all path-based backends", :shared => true do
  it "should accept a String path parameter" do
    instance = @klass.new(@tmpf.path)
    instance.should be
    instance.close!
  end

  it "should accept a Pathname path parameter" do
    instance = @klass.new(Pathname.new(@tmpf.path))
    instance.should be
    instance.close!
  end

  # Check that the backend rejects a path to a file that does not
  # exist with the proper exception.
  #
  # This ensure that the backends behave in a consistent way when it
  # comes to files or other data sources that don't exist (like 404
  # errors from HTTP).
  it "should reject a non-existent path" do
    # request a new temporary file, with an unique name...
    temp = Tempfile.new(description)
    # save the path right now, since after unlinking it would be nil.
    path = temp.path.to_s
    # ... and then remove it so that we know for sure it does not
    # exist.
    temp.unlink

    lambda do
      @klass.new(path)
    end.should raise_error(Bombe::NotFoundError)
  end

  # Check that the backend rejects opening a file that is not readable
  # to the user.
  #
  # This ensure that the backends behave in a consistent way when it
  # comes to files or other data sources that are not accessible (like
  # 403 errors from HTTP).
  it "should reject an inaccessible path" do
    # request a new temporary file
    temp = Tempfile.new(description)
    # and remove all its permissions
    temp.chmod(0000)

    lambda do
      @klass.new(temp.path)
    end.should raise_error(Bombe::PermissionError)

    temp.unlink
  end

  # Just for extra safety, make sure that it is possible to access
  # read-only files.
  #
  # Bombe is not designed to allow write access to a file, so we're
  # only interested in reading them. If the file is not writable we
  # have to be able to access it anyway.
  it "should allow accessing read-only files" do
    # Mark the file as read-only permission
    @tmpf.open
    @tmpf.chmod(0400)

    backend = @klass.new(@tmpf.path)
    backend.should be
    backend.close!
  end

  # Check that the backend rejects opening a directory rather than a
  # file.
  #
  # This ensures that the backends behave in a consistent way when it
  # comes to invalid paths.
  it "should reject a path pointing to directory" do
    lambda do
      @klass.new(Pathname.new(@tmpf.path) + "..")
    end.should raise_error(Bombe::DirectoryError)
  end
end

# Local Variables:
# mode: flyspell-prog
# mode: whitespace
# ispell-local-dictionary: "english"
# End:
