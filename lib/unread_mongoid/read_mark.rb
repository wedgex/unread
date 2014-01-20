class ReadMark
  include Mongoid::Document

  field :timestamp, type: Time

  belongs_to :readable, :polymorphic => true
  belongs_to :user

  validates_presence_of :user_id, :readable_type

  scope :global, -> { where(:readable_id => nil) }
  scope :single, -> { ne(readable_id: nil) }
  scope :older_than, -> (timestamp) { lt(timestamp: timestamp) }

  # Returns the class defined by acts_as_reader
  def self.reader_class
    reflect_on_all_associations(:belongs_to).find { |assoc| assoc.name == :user }.try(:klass)
  end

  class_attribute :readable_classes
end
