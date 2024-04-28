# frozen_string_literal: true

module Review
  def self.all_at_casino(id)
    db.execute('SELECT * FROM reviews WHERE casino_id=?', id)
  end

  def self.update(rating, amount, id)
    query = '
    UPDATE casinos
    SET rating=?, rev_amount=?
    WHERE id=?'

    db.execute(query, rating, amount, id)
  end

  def self.new(values)
    query = '
    INSERT INTO reviews
    (title, text, stars, parent, casino_id)
    VALUES (?,?,?,?,?)'

    db.execute(query, values)
  end

  def self.db
    if @db.nil?
      @db = SQLite3::Database.new('./db/db.sqlite')
      @db.results_as_hash = true
    end
    return @db
  end
end
