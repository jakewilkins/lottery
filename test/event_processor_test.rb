# frozen_string_literal: true

require_relative "test_helper"

class EventProcessorTest < Minitest::Test

  def setup
    @meeting = Meeting.new(id: :test, account: :account)
    @meeting.cleanup

    @person = Person.new(id: :bar, name: :bap)

    @redis = DB.pool.checkout
    @subject = EventProcessor
  end

  def teardown
    DB.pool.checkin
    @meeting.cleanup
  end

  def test_meeting_participant_joined
    event = {
      "accountId" => "account",
      "object" => {
        "id" => "test",
        "participant" => {
          "user_id" => "bar",
          "user_name" => "bap"
        }
      }
    }

    @subject.meeting_participant_joined(event)
    assert_equal "set", @redis.type(@meeting.key)
    assert_equal "bap", Person.find(id: @person.id).name
  end

  def test_meeting_participant_ended
    @meeting.cleanup
    @meeting << @person
    event = {
      "accountId" => "account",
      "object" => {
        "id" => "test",
        "participant" => {
          "user_id" => "bar",
          "user_name" => "bap"
        }
      }
    }

    @subject.meeting_participant_left(event)

    assert_equal "none", @redis.type(@meeting.key)
    assert_nil Person.find(id: @person.id).name
  end

  def test_meeting_ended
    @meeting << @person
    @meeting.shared(@person)
    event = {
      "accountId" => "account",
      "object" => {
        "id" => "test",
        "participant" => {
          "user_id" => "bar",
          "user_name" => "bap"
        }
      }
    }

    @subject.meeting_ended(event)

    assert_equal "none", @redis.type(@meeting.key)
    assert_equal "none", @redis.type(@meeting.called_on_key)
    assert_nil Person.find(id: @person.id).name
  end
end
