# frozen_string_literal: true

module Casino
  def self.all
    db.execute('SELECT * FROM casinos')
  end

  def self.select(id)
    db.execute('SELECT * FROM casinos WHERE id=?', id)
  end

  def self.select_at_name(name)
    db.execute('SELECT * FROM casinos WHERE name=?', name)
  end

  def self.by_id_with_cats(id)
    query = '
      SELECT *
      FROM casinos
      LEFT JOIN casinos_cats ON casinos.id = casinos_cats.id_casino
      LEFT JOIN cats ON casinos_cats.id_cat = cats.id
      WHERE id_casino=?'

    db.execute(query, id).first
  end

  def self.all_with_cats
    query = '
      SELECT id_casino, cats.name_cats, casinos.name
      FROM casinos
      LEFT JOIN casinos_cats ON casinos.id = casinos_cats.id_casino
      LEFT JOIN cats ON casinos_cats.id_cat = cats.id'

    sort_cats(db.execute(query))
  end

  def self.all_cats
    db.execute('SELECT * FROM cats')
  end

  def self.select_cat_at_name(name)
    db.execute('SELECT id FROM cats WHERE name_cats=?', name)
  end

  def self.new_casino(values)
    query = '
    INSERT INTO casinos
    (name, win_stats, turnover, logo_filepath, rating, rev_amount)
    VALUES (?,?,?,?,?,?) RETURNING id'

    _values = values
    _values << 0
    _values << 0

    db.execute(query, _values)
  end

  def self.new_casino_cat(id_casino, id_cat)
    query = '
    INSERT INTO casinos_cats
    (id_casino, id_cat)
    VALUES (?,?)'

    db.execute(query, id_casino, id_cat)
  end

  def self.update_casino(values, name)
    query_update_casino = '
    UPDATE casinos
    SET win_stats=?, turnover=?, logo_filepath=?
    WHERE name=?
    RETURNING id'

    db.execute(query_update_casino, values, name)
  end

  def self.update_or_create(id, params)
    if id.nil?
      new_casino(params.values)
    end

    list = []

    list << params['win_stats']
    list << params['turn_over']
    list << params['logo_filepath']

    update_casino(list, params['casino_name'])
  end

  def self.set_rating(id, stars)
    query_set = '
    UPDATE casinos
    SET rating = (rating * rev_amount + ?) / rev_amount, rev_amount = rev_amount + 1
    WHERE id=?'

    db.execute(query_set, stars, id)
  end

  def self.sort_cats(hash_of_cats)
    array_of_cats = {}

    hash_of_cats.each do |cats|
      if array_of_cats[cats['id_casino'].to_s].nil?
        array_of_cats[cats['id_casino'].to_s] = []
      end
      array_of_cats[cats['id_casino'].to_s].append(cats['name_cats'])
    end

    array_of_cats
  end

  def self.db
    if @db.nil?
      @db = SQLite3::Database.new('./db/db.sqlite')
      @db.results_as_hash = true
    end
    return @db
  end
end
