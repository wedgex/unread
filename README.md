Unread-Mongoid
======

Ruby gem to manage read/unread status of Mongoid objects.

## Credit
First and foremost this is a fork of [Unread](https://github.com/ledermann/unread) by [Georg Ledermann](http://www.georg-ledermann.de). If you are using a relational DB, make sure to check it out.

## Features

* Manages unread records for anything you want users to read (like messages, documents, comments etc.)
* Supports _mark as read_ to mark a **single** record as read
* Supports _mark all as read_ to mark **all** records (loops through creating a readmark for each)
* Gives you a scope to get the unread or read records for a given user
* Needs only one additional collection

## Usage

```ruby
class User
  include Mongoid::Document
  include UnreadMongoid

  acts_as_reader
end

class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  include UnreadMongoid
  acts_as_readable
end

message1 = Message.create!
message2 = Message.create!

## Get unread messages for a given user
Message.unread_by(current_user).entries
# => [ message1, message2 ]

message1.mark_as_read! :for => current_user
Message.unread_by(current_user).entries
# => [ message2 ]

Message.mark_as_read! :all, :for => current_user
Message.unread_by(current_user).entries
# => [ ]
```
