# frozen_string_literal: true

require_relative "test_helper"

class InteractionProcessorTest < Minitest::Test
  def setup
    @meeting = Meeting.new(id: :test, account: :account)
    @meeting.cleanup

    @person = Person.new(id: "foo", name: "bar")

    @redis = DB.pool.checkout
    @subject = InteractionProcessor
  end

  def teardown
    DB.pool.checkin
    @meeting.cleanup
  end

  def test_mark_sharing
    @meeting << @person
    event = {
      "actionItem" => {
        "value" => "mark-sharing:account.test.foo"
      },
      "messageId" => "messageID"
    }

    @subject.call(event)

    assert_equal "set", @redis.type(@meeting.called_on_key)
  end

  def test_reset_sharing
    @meeting << @person
    event = {
      "actionItem" => {
        "value" => "mark-sharing:account.test.foo"
      },
      "messageId" => "messageID"
    }

    response = @subject.call(event)

    assert_equal "set", @redis.type(@meeting.called_on_key)
    assert_equal :person_sharing, response.type
  end


  def test_draw_again
    @meeting << @person
    event = {
      "actionItem" => {
        "value" => "reset-shared:account.test"
      },
      "messageId" => "messageID"
    }

    response = @subject.call(event)

    assert_equal "none", @redis.type(@meeting.called_on_key)
    assert_equal :sharing_reset, response.type
  end
end
