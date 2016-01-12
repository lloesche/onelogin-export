require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |spec|
  spec.name = 'onelogin-export'
  spec.summary = 'A library for exporting OneLogin users'
  spec.description = <<-TEXT
A library for exporting OneLogin users.
  TEXT
  spec.author = 'Lukas Loesche'
  spec.email = 'lukas@mesosphere.io'
  spec.homepage = 'http://www.mesosphere.io/'
  spec.files = Dir['lib/**/*.rb']
  spec.bindir = 'bin'
  spec.executables << 'onelogin-user-export'
  spec.version = '0.3'
  spec.add_dependency 'unicode_utils'
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end
