#encoding: UTF-8
Gem::Specification.new do |s|
  s.name          = "hadoopconf_gem"
  s.email         = "msouza@alpinenow.com "
  s.version       = "0.0.1"
  s.date          = "2015-06-16"
  s.description   = "Description"
  s.summary       = "Summary"
  s.authors       = ["Michael Souza"]
  s.homepage      = "http://alpinenow.com"
  s.license       = "NONE"

  # files = []
  # files << "readme.md"
  # files << Dir["sql/**/*.sql"]
  # files << Dir["{lib,test}/**/*.rb"]
  # s.files = files
  # s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

  s.require_paths = %w[hadoopconf]
  s.add_dependency "httparty"
end