module Unread
  module Readable
    module Scopes
      # TODO rename some of these
      def read_marks_for(user)
        assert_reader(user)

        ReadMark.where(readable_type: self.name, user_id: user._id)
      end

      def read_mark_ids(user)
        ids = read_marks_for(user).ne(readable_id: nil).only(:readable_id).map(&:readable_id)
        ids += blanket_read_for_ids(user)

        ids
      end

      def blanket_read_for_ids(user)
        blanket = read_marks_for(user).where(readable_id: nil).sort(timestamp: :desc).first

        if blanket
          self.lte(self.readable_options[:on] => blanket.timestamp).only(:_id).map(&:_id)
        else
          []
        end
      end

      def unread_by(user)
        self.not_in(_id: read_mark_ids(user))
      end

      def read_by(user)
        self.in(_id: read_mark_ids(user))
      end
    end
  end
end
