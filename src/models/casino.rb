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
      WHERE casinos.id=?'

    db.execute(query, id)
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

    values.pop
    values.shift
    _values = values
    _values << 0
    _values << 0

    db.execute(query, _values).first['id']
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
    if id == ""
      test = new_casino(params.values)
      return test
    end

    list = []

    list << params['win_stats']
    list << params['turn_over']
    list << params['logo_filepath']

    return update_casino(list, params['casino_name']).first['id']
  end

  def self.delete(casino_name)
    casino_query = '
    DELETE FROM casinos
    WHERE name=?
    returning id'

    cats_query = '
    DELETE FROM casinos_cats
    WHERE id_casino=?'

    begin
      id = db.execute(casino_query, casino_name).first['id']
    rescue => error
      puts "#{casino_name} does not exist"
      return 0
    end

    puts "should not be here"
    db.execute(cats_query, id)
  end

  def self.delete_by_id(id)
    casino_query = '
    DELETE FROM casinos
    WHERE id=?'

    cats_query = '
    DELETE FROM casinos_cats
    WHERE id_casino=?'

    puts 'this is the id'
    p id
    begin
      db.execute(casino_query, id)
    rescue => error
      puts 'it couldnt delete the casino'
      p error
      return 0
    end

    db.execute(cats_query, id)
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
