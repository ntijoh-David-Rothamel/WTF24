class App < Sinatra::Base
  require '../src/db/seed'

  enable :sessions

  def db
    if @db.nil?
      @db = SQLite3::Database.new('./db/db.sqlite')
      @db.results_as_hash = true
    end
    return @db
  end

  get '/' do
    redirect '/casinos'
  end

  get '/casinos' do
    @casinos = db.execute(
      'SELECT * FROM casinos'
    )

    casinos_cats = db.execute(
      'SELECT id_casino, cats.name_cats, casinos.name
      FROM casinos
      LEFT JOIN casinos_cats ON casinos.id = casinos_cats.id_casino
      LEFT JOIN cats ON casinos_cats.id_cat = cats.id'
    )

    p casinos_cats

    @casinos_cats = sort_cats(casinos_cats)

    p @casinos_cats

    erb :'casinos/index'
  end

  get '/casinos/new' do
    @cats = db.execute('SELECT * FROM cats')
    @casino = [{ 'name' => '', 'win_stats' => '', 'turn_over' => '', 'logo_filepath' => '', 'rating' => '' }]
    erb :'casinos/edit'
  end

  get '/casinos/:id' do |id|
    @casino = db.execute('SELECT * FROM casinos WHERE id=?', id).first

    p @casino

    @reviews = db.execute('SELECT * FROM reviews WHERE casino_id=?', id)

    erb :'/casinos/show'
  end

  get '/casinos/:id/edit' do |id|
    query = '
      SELECT *
      FROM casinos
      LEFT JOIN casinos_cats ON casinos.id = casinos_cats.id_casino
      LEFT JOIN cats ON casinos_cats.id_cat = cats.id
      WHERE id_casino=?'

    @casino = db.execute(query, id)

    p @casino

    @cats = db.execute('SELECT * FROM cats')

    erb :'/casinos/edit'
  end

  get '/users' do
    erb :'/users/index'
  end

  get '/users/new' do
    erb :'/users/signin'
  end

  get '/seed' do
    Seeder.seed!
    redirect '/users'
  end

  post '/casinos' do
    casino = params.dup
    casino.delete('cats')
    casino.delete('submit')

    casino_values = casino.values

    query_casino = '
    INSERT INTO casinos
    (name, win_stats, turnover, logo_filepath, rating)
    VALUES (?,?,?,?,?) RETURNING id'

    query_update_casino = '
    UPDATE casinos
    SET win_stats=?, turnover=?, logo_filepath=?, rating=?
    WHERE name=?
    RETURNING id'

    query_cats = '
    INSERT INTO cats
    (name_cats)
    VALUES (?) RETURNING id'

    query_cats_casino = '
    INSERT INTO casinos_cats
    (id_casino, id_cat)
    VALUES (?,?)'

    check = db.execute('SELECT id FROM casinos WHERE name=?', casino['casino_name']).first

    if check.nil?
      casino_id = db.execute(query_casino, casino_values).first
    else
      casino_values.delete_at(0)
      casino_id = db.execute(query_update_casino, casino_values, casino['casino_name']).first
    end

    cats_id = db.execute('SELECT id FROM cats WHERE name_cats=?', params['cats']).first

    if cats_id.nil?
      cats_id = db.execute(query_cats, params['cats']).first
    end

    db.execute(query_cats_casino, casino_id['id'], cats_id['id'])

    redirect "/casinos/#{casino_id['id']}/edit"
  end

  post '/reviews' do
    values = params.values
    p values
    p params

    query = '
    INSERT INTO reviews
    (title, text, stars, parent, casino_id)
    VALUES (?,?,?,?,?)'

    query_get_rating = '
    SELECT rating, rev_amount, id
    FROM casinos'

    query_set_rating = '
    UPDATE casinos
    SET rating=?, rev_amount=?
    WHERE id=?'

    rating_values = db.execute(query_get_rating).first

    rating_values['rating'] = (rating_values['rating'].to_i * rating_values['rev_amount'].to_i + params['stars'].to_i) / (rating_values['rev_amount'].to_i + 1)

    rating_values['rev_amount'] = 1 + rating_values['rev_amount'].to_i

    db.execute(query, values)

    db.execute(query_set_rating, rating_values['rating'], rating_values['rev_amount'], rating_values['id'])

    redirect "/casinos/#{values[-1]}"
  end

  post '/users' do
    username = params['username']
    clear_pass = params['password']


  end

  post '/users/new' do
    password = BCrypt::Password.create(params['password'])

    query = '
    INSERT INTO users
    (name, password, email)
    VALUES (?,?,?)'

    db.execute(query, params['username'], password, params['email'])

    redirect '/users'
  end
  def sort_cats(hash_of_cats)
    array_of_cats = {}

    hash_of_cats.each do |cats|
      if array_of_cats[cats['id_casino'].to_s].nil?
        array_of_cats[cats['id_casino'].to_s] = []
      end
      array_of_cats[cats['id_casino'].to_s].append(cats['name_cats'])
    end

    array_of_cats
  end

  def sort_revs(hash_of_revs)
    #Should sort the rev elements in a way
    # so that
  end
end
