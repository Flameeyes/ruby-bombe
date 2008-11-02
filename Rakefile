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
