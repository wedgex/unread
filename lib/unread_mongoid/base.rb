module UnreadMongoid
  def self.included(base)
    base.extend Base
  end

  module Base
    def acts_as_reader
      include Reader
    end

    def acts_as_readable
      has_many :read_marks, as: :readable

      before_save do |readable|
        readable.read_marks.delete_all
      end

      include Readable::InstanceMethods
      extend Readable::ClassMethods
      extend Readable::Scopes
    end
  end
end
