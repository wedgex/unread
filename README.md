Unread-Mongoid
======

Ruby gem to manage read/unread status of Mongoid objects.

## Credit
First and foremost this is a fork of [Unread](https://github.com/ledermann/unread) by [Georg Ledermann](http://www.georg-ledermann.de). If you don't need to use Mongoid I highly reccoment you use his gem, this is a task much better suited to a relational db, I had to remove some features to make it work for Mongoid.

## Features

* Manages unread records for anything you want users to read (like messages, documents, comments etc.)
* Supports _mark as read_ to mark a **single** record as read
* Supports _mark all as read_ to mark **all** records as read in a single step
* Gives you a scope to get the unread or read records for a given user
* Needs only one additional collection


## Requirements

* Ruby 1.8.7 or 1.9.3 or 2.0.0
* Rails 3 (including 3.0, 3.1, 3.2) and Rails 4.
* Needs a timestamp field in your models (like created_at or updated_at) with a database index on it


## Installation

Step 1: Add this to your Gemfile:

```ruby
gem 'unread-mongoid'
```

and run

```shell
bundle
```


## Usage

```ruby
class User < ActiveRecord::Base
  include Mongoid::Document
  include Unread

  acts_as_reader
end

class Message < ActiveRecord::Base
  include Mongoid::Document
  include Mongoid::Timestamps

  include Unread
  acts_as_readable :on => :created_at
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

# Optional: Cleaning up unneeded markers.
# Do this in a cron job once a day.
Message.cleanup_read_marks!
```
