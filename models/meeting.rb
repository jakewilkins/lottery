# frozen_string_literal: true

class Meeting
  KEY_PATTERN = "meeting:%<id>s"
  NAME_KEY_PATTERN = "meeting:%<id>s:%<person>s"
  CALLED_KEY = "meeting:%<id>s:called"

  attr_reader :id

  def self.find(id)
    new(id: id)
  end

  def initialize(id:)
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

  def draw
    begin
      candidate = draw_candidate
    end until candidate_available?(candidate)

    candidate_called_on(candidate)

    DB { |conn| conn.get(person_key(candidate)) }
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
    DB { |conn| conn.sismember(called_on_key, id) }
  end

  def key
    KEY_PATTERN % {id: id}
  end

  def person_key(person_id)
    NAME_KEY_PATTERN % {id: id, person: person_id}
  end

  def called_on_key
    CALLED_KEY % {id: id}
  end

end
