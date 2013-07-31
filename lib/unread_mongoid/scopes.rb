module UnreadMongoid
  module Readable
    module Scopes
      # TODO rename some of these

      def unread_by(user)
        self.not_in(_id: read_ids(user))
      end

      def read_by(user)
        self.in(_id: read_ids(user))
      end

      private
      def read_marks_query(user)
        assert_reader(user)

        ReadMark.where(readable_type: self.name, user_id: user._id)
      end

      def blanket_marks_query(user)
        read_marks_query(user).and(readable_id: nil).sort(timestamp: :desc)
      end

      def read_ids(user)
        specifically_marked_ids(user) + blanketed_ids(user)
      end

      def blanketed_ids(user)
        blanket = blanket_marks_query(user).first

        if blanket
          self.lte(self.readable_options[:on] => blanket.timestamp).only(:_id).map(&:_id)
        else
          []
        end
      end

      def specifically_marked_ids(user)
        read_marks_query(user).ne(readable_id: nil).only(:readable_id).map(&:readable_id)
      end
    end
  end
end
