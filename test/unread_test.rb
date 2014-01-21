require 'test_helper'

class UnreadTest < ActiveSupport::TestCase
  def setup
    @reader = User.create! :name => 'David'
    @other_reader = User.create :name => 'Matz'

    wait
    @email1 = Email.create!
    wait
    @email2 = Email.create!
  end

  def teardown
    User.delete_all
    Email.delete_all
    ReadMark.delete_all
    Timecop.return
  end

  def test_scope
    assert_equal [@email1, @email2], Email.unread_by(@reader)
    assert_equal [@email1, @email2], Email.unread_by(@other_reader)

    assert_equal 2, Email.unread_by(@reader).count
    assert_equal 2, Email.unread_by(@other_reader).count
  end

  def test_read_by
    @email1.mark_as_read! :for => @reader

    assert_equal [@email1], Email.read_by(@reader).entries
  end

  def test_scope_param_check
    [ 42, nil, 'foo', :foo, {} ].each do |not_a_reader|
      assert_raise(ArgumentError) { Email.unread_by(not_a_reader) }
      assert_raise(ArgumentError) { Email.read_by(not_a_reader) }
    end
  end

  def test_scope_after_reset
    @email1.mark_as_read! :for => @reader

    assert_equal [@email2], Email.unread_by(@reader).entries
    assert_equal 1, Email.unread_by(@reader).count
  end

  def test_unread_after_create
    assert_equal true, @email1.unread?(@reader)
    assert_equal true, @email1.unread?(@other_reader)

    assert_raise(ArgumentError) {
      @email1.unread?(42)
    }
  end

  def test_unread_after_update
    @email1.mark_as_read! :for => @reader
    wait
    @email1.update_attributes! :subject => 'changed'

    assert_equal true, @email1.unread?(@reader)
  end

  def test_mark_as_read
    @email1.mark_as_read!(:for => @reader)

    assert_equal false, @email1.unread?(@reader)
    assert_equal [@email2], Email.unread_by(@reader).entries

    assert_equal true, @email1.unread?(@other_reader)
    assert_equal [@email1, @email2], Email.unread_by(@other_reader).entries
  end

  def test_mark_as_read_multiple
    assert_equal true, @email1.unread?(@reader)
    assert_equal true, @email2.unread?(@reader)

    Email.mark_as_read! [ @email1, @email2 ], :for => @reader

    assert_equal false, @email1.unread?(@reader)
    assert_equal false, @email2.unread?(@reader)
  end

  def test_mark_as_read_twice
    @email1.mark_as_read! :for => @reader
    @email1.mark_as_read! :for => @reader

    assert_equal 1, ReadMark.where(reader: @reader).count
  end

  def test_mark_all_as_read
    Email.mark_as_read! :all, :for => @reader

    assert_equal [], Email.unread_by(@reader)
  end

private
  def wait
    Timecop.freeze(1.minute.from_now.change(:usec => 0))
  end
end
