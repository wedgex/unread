# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "unread_mongoid/version"

Gem::Specification.new do |s|
  s.name        = "unread-mongoid"
  s.version     = UnreadMongoid::VERSION
  s.authors     = ["Hunter Haydel", "Georg Ledermann"]
  s.email       = ["haydh530@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Manages read/unread status of Mongoid objects}
  s.description = %q{This gem creates a scope for unread objects and adds methods to mark objects as read }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'mongoid', ['~> 3.1.0', "< 4.1.0"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'timecop'
end
