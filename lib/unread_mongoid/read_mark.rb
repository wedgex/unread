class ReadMark
  include Mongoid::Document

  belongs_to :readable, polymorphic: true, index: true
  belongs_to :reader, polymorphic: true, index: true

  validates_presence_of :reader_id, :reader_type, :readable_id, :readable_type
  validates :reader_id, uniqueness: { scope: [:reader_type, :readable_id, :readable_type] }
end
