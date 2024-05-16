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
    VALUES (?,?)'

    query_get = '
    SELECT id FROM cats
    WHERE name_cats=?'


    begin
      cat_id = db.execute(query_cats, name).first['id']
    rescue => e
      cat_id = db.execute(query_get, name).first['id']
    end

    db.execute(query_casino_cats, id, cat_id)
  end

  def self.db
    if @db.nil?
      @db = SQLite3::Database.new('./db/db.sqlite')
      @db.results_as_hash = true
    end
    return @db
  end
end
