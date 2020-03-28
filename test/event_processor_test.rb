# frozen_string_literal: true

require_relative "test_helper"

class EventProcessorTest < Minitest::Test

  def setup
    @meeting = Meeting.new(id: :test, account: :account)
    @meeting.cleanup

    @redis = DB.pool.checkout
    @subject = EventProcessor
  end

  def teardown
    DB.pool.checkin
    @meeting.cleanup
  end

  def test_meeting_participant_joined
    event = {
      "id" => "test",
      "accountId" => "account",
      "participant" => {
        "user_id" => "bar",
        "user_name" => "bap"
      }
    }

    @subject.meeting_participant_joined(event)
    assert_equal "set", @redis.type("meeting:account:test")
    assert_equal "bap", @redis.get("meeting:account:test:bar")
  end

  def test_meeting_participant_ended
    @meeting.cleanup
    @meeting << {id: :bar, name: :bar}
    event = {
      "id" => "test",
      "accountId" => "account",
      "participant" => {
        "user_id" => "bar",
        "user_name" => "bap"
      }
    }

    @subject.meeting_participant_left(event)

    assert_equal "none", @redis.type("meeting:account:test")
    assert_nil @redis.get("meeting:account:test:foo")
  end

  def test_meeting_ended
    @meeting << {id: :foo, name: :bar}
    @meeting.shared(person: :foo)
    event = {
      "id" => "test",
      "accountId" => "account",
      "participant" => {
        "user_id" => "bar",
        "user_name" => "bap"
      }
    }

    @subject.meeting_ended(event)

    assert_equal "none", @redis.type("meeting:account:test")
    assert_equal "none", @redis.type("meeting:account:test:called")
    assert_nil @redis.get("meeting:account:test:foo")
  end
end
