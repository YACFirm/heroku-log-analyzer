Gem::Specification.new do |s|
  s.name = "heroku-log-analyzer"
  s.version = "0.0.2"
  s.date = "2013-06-19"
  s.summary = "Heroku log parser and storage"
  s.description = "desc"
  s.authors = ["YACFirm"]
  s.email = 'team@yacfirm.com'
  s.files = ['lib/heroku-log-analyzer.rb', 'lib/tasks/dbcreate.rake']
  s.homepage = "https://github.com/YACFirm/heroku-log-analyzer"

  s.add_dependency 'activerecord', "~> 3.2.12"
  s.add_dependency 'activerecord-import', "~> 0.3.1"
end
