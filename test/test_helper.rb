require 'test/unit'
require 'mongoid'
require 'timecop'

ENV['MONGOID_ENV'] = 'test'
Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml')

require 'unread_mongoid'

class User
  include Mongoid::Document
  include UnreadMongoid

  acts_as_reader

  field :name, type: String
end

class Email
  include Mongoid::Document
  include Mongoid::Timestamps

  include UnreadMongoid

  acts_as_readable

  field :subject, type: String
  field :content, type: String
end

puts "Testing with Mongoid #{Mongoid::VERSION}"
