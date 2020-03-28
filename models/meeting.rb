# frozen_string_literal: true

class Meeting
  KEY_PATTERN = "meeting:%<account_id>s:%<id>s"
  NAME_KEY_PATTERN = "#{KEY_PATTERN}:%<person>s"
  CALLED_KEY = "#{KEY_PATTERN}:called"

  attr_reader :id, :account_id

  def self.find(id, account:)
    new(id: id, account: account)
  end

  def initialize(id:, account:)
    @account_id = account
    @id = id
  end

  def <<(id:, name:)
    DB do |conn|
      conn.sadd(key, id)
      conn.set(person_key(id), name)
    end
  end

  def >>(id:)
    DB do |conn|
      conn.srem key, id
      conn.del(person_key(id))
    end
  end

  def shared(person:)
    candidate_called_on(person)
  end

  def draw
    if everyone_has_shared?
      return Person.new(meeting_id: id, id: :empty, name: "Everyone has shared!")
    end

    tries = 0
    begin
      candidate = draw_candidate
      tries += 1
    end until candidate_available?(candidate) || tries > 10

    name = DB { |conn| conn.get(person_key(candidate)) }

    Person.new(
      meeting_id: id,
      id: candidate,
      name: name
    )
  end

  def clear_shared
    DB { |conn| conn.del(called_on_key) }
  end

  def cleanup
    DB { |conn|
      person_keys = conn.keys("#{key}:*")
      person_keys.each { |k| conn.del(k) }
      conn.del(key)
      conn.del(called_on_key)
    }
  end

  def alive?
    DB { |conn| conn.exists(key) }
  end

  private

  def draw_candidate
    DB { |conn| conn.srandmember(key) }
  end

  def candidate_called_on(id)
    DB { |conn| conn.sadd(called_on_key, id) }
  end

  def candidate_available?(id)
    !DB { |conn| conn.sismember(called_on_key, id) }
  end

  def everyone_has_shared?
    DB { |conn|
      conn.scard(called_on_key) == conn.scard(key)
    }
  end

  def key
    KEY_PATTERN % {id: id, account_id: account_id}
  end

  def person_key(person_id)
    NAME_KEY_PATTERN % {id: id, person: person_id, account_id: account_id}
  end

  def called_on_key
    CALLED_KEY % {id: id, account_id: account_id}
  end

end
