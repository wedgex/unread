module UnreadMongoid
  module Readable
    module Scopes
      def unread_by(reader)
        UnreadMongoid::Reader.assert_reader(reader)

        self.not_in(id: read_ids(reader))
      end

      def read_by(reader)
        UnreadMongoid::Reader.assert_reader(reader)

        self.in(id: read_ids(reader))
      end

      private
      def read_ids(reader)
        ReadMark.where(
          reader_id: reader.id,
          reader_type: reader.class.name,
          readable_type: self.name
        ).only(:readable_id).map(&:readable_id)
      end
    end
  end
end
