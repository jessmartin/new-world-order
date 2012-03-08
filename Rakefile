desc "Run template with defaults"
task :test do
  system "rm -rf tmp/r3-test"
  system "rails new tmp/r3-test -m template.rb"
end

task :test_postgres do
  system "rm -rf tmp/pg-test"
  system "rails new tmp/pg-test -d postgresql -m template.rb"
end

task :default => [:test]
