module UnreadMongoid
  module Readable
    module ClassMethods
      def mark_as_read!(target, options)
        user = options[:for]
        assert_reader(user)

        if target == :all
          reset_read_marks_for_user(user)
        elsif target.is_a?(Array)
          mark_array_as_read(target, user)
        else
          raise ArgumentError
        end
      end

      def mark_array_as_read(array, user)
        array.each do |obj|
          raise ArgumentError unless obj.is_a?(self)

          rm = obj.read_marks.where(user_id: user._id).first || obj.read_marks.build(user_id: user._id)
          rm.timestamp = obj.send(readable_options[:on])
          rm.save!
        end
      end

      # A scope with all items accessable for the given user
      # It's used in cleanup_read_marks! to support a filtered cleanup
      # Should be overriden if a user doesn't have access to all items
      # Default: User has access to all items and should read them all
      #
      # Example:
      #   def Message.read_scope(user)
      #     user.visible_messages
      #   end
      def read_scope(user)
        self
      end

      def cleanup_read_marks!
        assert_reader_class

        ReadMark.reader_class.each do |user|
          if oldest_timestamp = read_scope(user).unread_by(user).sort(readable_options[:on] => :asc).first.send(readable_options[:on])
            # There are unread items, so update the global read_mark for this user to the oldest
            # unread item and delete older read_marks
            update_read_marks_for_user(user, oldest_timestamp)
          else
            # There is no unread item, so deletes all markers and move global timestamp
            reset_read_marks_for_user(user)
          end
        end
      end

      def update_read_marks_for_user(user, timestamp)
        # Delete markers OLDER than the given timestamp
        user.read_marks.where(:readable_type => self.name).single.older_than(timestamp).delete_all

        # Change the global timestamp for this user
        rm = user.read_mark_global(self) || user.read_marks.build(:readable_type => self.name)
        rm.timestamp = timestamp - 1.second
        rm.save!
      end

      def reset_read_marks_for_all
        ReadMark.delete_all :readable_type => self.name
        ReadMark.reader_class.each do |user|
          ReadMark.create!(user_id: user._id, readable_type: self.name, timestamp: Time.current.to_s(:db))
        end
      end

      def reset_read_marks_for_user(user)
        assert_reader(user)

        ReadMark.delete_all :readable_type => self.name, :user_id => user._id
        ReadMark.create!    :readable_type => self.name, :user_id => user._id, :timestamp => Time.now
      end

      def assert_reader(user)
        assert_reader_class

        unless user.is_a?(ReadMark.reader_class)
          raise ArgumentError, "Class #{user.class.name} is not registered by acts_as_reader!"
        end

        unless user._id
          raise ArgumentError, "The given user has no id!"
        end
      end

      def assert_reader_class
        raise RuntimeError, 'There is no class using acts_as_reader!' unless ReadMark.reader_class
      end
    end

    module InstanceMethods
      def unread?(user)
        self.class.unread_by(user).and(_id: self._id).exists?
      end

      def mark_as_read!(options)
        user = options[:for]
        self.class.assert_reader(user)

        if unread?(user)
          rm = read_mark(user) || read_marks.build(:user_id => user._id)
          rm.timestamp = self.send(readable_options[:on]).to_s(:db)
          rm.save!
        end
      end

      def read_mark(user)
        read_marks.where(:user_id => user._id).first
      end
    end
  end
end
