module UnreadMongoid
  module Readable
    module ClassMethods
      def mark_as_read!(target, options)
        reader = options[:for]
        UnreadMongoid::Reader.assert_reader(reader)

        readables_to_mark = if(target == :all)
                              self.unread_by(reader)
                            else
                              target
                            end

        self.unread_by(reader).each do |readable|
          raise ArgumentError unless readable.is_a? self

          readable.mark_as_read! :for => reader
        end
      end
    end

    module InstanceMethods
      def unread?(reader)
        UnreadMongoid::Reader.assert_reader(reader)

        ReadMark.where(reader: reader, readable: self).empty?
      end

      def mark_as_read!(options)
        reader = options[:for]
        UnreadMongoid::Reader.assert_reader(reader)

        ReadMark.create(reader: reader, readable: self)
      end
    end
  end
end
