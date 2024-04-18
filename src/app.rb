require_relative 'models/casino'

class App < Sinatra::Base
  require '../src/db/seed'

  enable :sessions

  get '/' do
    redirect '/casinos'
  end

  get '/test' do
    erb :'/casinos/test'
  end

  get '/casinos' do
    @user = User.by_session_id

    @casinos = Casino.all

    casinos_cats = Casino.all_with_cats
    #TODO Move sort to models
    @casinos_cats = sort_cats(casinos_cats)

    erb :'/casinos/index'
  end

  get '/casinos/new' do
    @user = User.by_session_id

    @cats = Casino.all_cats

    @casino = [{'id' => nil, 'name' => '', 'win_stats' => '', 'turn_over' => '', 'logo_filepath' => '', 'rating' => '' }]

    erb :'/casinos/edit'
  end

  get '/casinos/:id' do |id|
    @user = User.by_session_id

    @casino = Casino.select(id).first

    @reviews = Review.all_at_casino(id)

    erb :'/casinos/show'
  end

  get '/casinos/:id/edit' do |id|
    @user = User.by_session_id

    @casino = Casino.by_id_with_cats(id)

    @cats = Casino.all_cats

    erb :'/casinos/edit'
  end

  get '/users' do
    @user = User.by_session_id

    erb :'/users/index'
  end

  get '/users/new' do
    @user = User.by_session_id

    erb :'/users/signin'
  end

  get '/users/logout' do
    session.destroy

    redirect '/'
  end

  get '/users/edit' do
    @user = User.by_session_id

    @users = User.all_users

    @roles = User.all_roles

    erb :'/users/edit'
  end

  get '/seed' do
    Seeder.seed!
    redirect '/users'
  end

  post '/casinos' do
    id = Casino.update_or_create(params['id'], params)

    Cats.new(params['cats'], id)

    redirect "/casinos/#{id}/edit"
  end

  post '/casinos' do
    casino = params.dup
    casino.delete('cats')

    #TODO should not require removal of submit
    # Just remove value from submit
    #casino.delete('submit')

    casino_values = casino.values

    #TODO set default values for rating and rev_amount to zero

    check = Casino.select_at_name(casino['casino_name']).first

    #TODO This logic should be put into the model

    if check.nil?
      casino_id = Casino.new_casino(casino_values).first
    else
      casino_values.delete_at(0)
      casino_id = Casino.update_casino(casino_values, casino['casino_name']).first
    end

    cats_id = Casino.select_cat_at_name(params['cats']).first

    if cats_id.nil?
      cats_id = Casino.new_cat(params['cats']).first
    end

    Casino.new_casino_cat(casino_id['id'], cats_id['id'])

    redirect "/casinos/#{casino_id['id']}/edit"
  end

  post '/reviews' do
    values = params.values

    query_get_rating =

    rating_values = db.execute(query_get_rating).first

    rating_values['rating'] = (rating_values['rating'].to_i * rating_values['rev_amount'].to_i + params['stars'].to_i) / (rating_values['rev_amount'].to_i + 1)

    rating_values['rev_amount'] = 1 + rating_values['rev_amount'].to_i

    Review.new(values)

    db.execute(query_set_rating, rating_values['rating'], rating_values['rev_amount'], rating_values['id'])

    redirect "/casinos/#{values[-1]}"
  end

  post '/reviews' do
    Review.new(params.values)

    Casino.set_rating(params['parent'], params['stars'])
  end


  post '/users' do
    username = params['username']
    clear_pass = params['password']

    user = db.execute('SELECT * FROM users WHERE username = ?', username).first

    pass_db = BCrypt::Password.new(user['password'])

    if pass_db == clear_pass
      session[:user_id] = user['id']
      redirect "/"
    else
      redirect "/users"
    end
  end

  post '/users/new' do
    password = BCrypt::Password.create(params['password'])

    query_user = '
    INSERT INTO users
    (username, password, email)
    VALUES (?,?,?)
    RETURNING id'

    query_user_role = '
    INSERT INTO users_roles
    (user_id, role_id)
    VALUES (?,?)'

    user_id = db.execute(query_user, params['username'], password, params['email']).first

    # Pray that I don't change the id of user
    db.execute(query_user_role, user_id[0], 4)

    redirect '/users'
  end

  post '/users/edit' do
    #TODO maybe download hole db just one time
    # instead of loading just the id i need
    # what is faster?

    query_role = '
    SELECT id FROM roles
    WHERE rolename=?'

    query_user_role = '
    UPDATE users_roles
    SET role_id=?
    WHERE user_id=?'

    p params

    params.each do |role|
      role_id = db.execute(query_role, role[1]).first

      p role_id

      db.execute(query_user_role, role_id['id'], role[0])
    end

    redirect '/users/edit'
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

  def h(text)
    Rack::Utils.escape_html(text)
  end

end
