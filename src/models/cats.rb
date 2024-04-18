# frozen_string_literal: true

module Cats
  def self.new(name, id)
    query_cats = '
    INSERT INTO cats
    (name_cats)
    VALUES (?) RETURNING id'

    query_casino_cats = '
    INSERT INTO casinos_cats
    (id_casino, id_cat)
    VALUES (?,?)
'

    begin
      cat_id = db.execute(query, name)
    rescue SQLException::ConstraintException
      return nil
    end

    db.execute(id, cat_id)
  end

  def db
    if db.nil?
      db = SQLite3::Database.new('./db/db.sqlite')
      db.results_as_hash = true
    end
    return db
  end
end
