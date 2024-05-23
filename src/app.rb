require_relative 'models/casino'
require_relative 'models/cats'
require_relative 'models/review'
require_relative 'models/user'

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

  before do
    @user = User.by_id(session[:user_id])
  end

  get '/' do
    redirect '/casinos'
  end

  #Used for making the cypress tests easier
  get '/test' do
    User.delete('linus')
    Casino.delete('då var det dags igen')

    erb :'/casinos/test'
  end

  get '/casinos' do
    @casinos = Casino.all

    @casinos_cats = Casino.all_with_cats

    erb :'/casinos/index'
  end

  get '/casinos/new' do
    @cats = Casino.all_cats

    @casino = [{ 'id' => nil,
                 'name' => '',
                 'win_stats' => '',
                 'turn_over' => '',
                 'logo_filepath' => '',
                 'rating' => '',
                 'name_cats' => nil }]

    erb :'/casinos/edit'
  end

  get '/casinos/:id' do |id|
    @casino = Casino.select(id).first

    @reviews = Review.all_at_casino(id)

    erb :'/casinos/show'
  end

  get '/casinos/:id/edit' do |id|
    @casino = Casino.by_id_with_cats(id)

    @cats = Casino.all_cats

    erb :'/casinos/edit'
  end

  get '/users' do
    erb :'/users/index'
  end

  get '/users/failed' do
    @login_failed = true
    sleep(5)
    erb :'/users/index'
  end

  get '/users/new' do
    erb :'/users/signin'
  end

  get '/users/logout' do
    session.destroy

    redirect '/'
  end

  get '/users/edit' do
    @users = User.all_users

    @roles = User.all_roles

    erb :'/users/edit'
  end

  get '/seed' do
    Seeder.seed!
    redirect '/users'
  end

  before '/casinos' do
    role = User.by_id(session[:user_id])

    if request.request_method == 'POST' && (role.nil? || !role['write'])
      redirect back
    end
  end

  post '/casinos' do
    id = Casino.update_or_create(params['id'], params)

    Cats.new(params['cats'], id)

    redirect "/casinos/#{id}/edit"
  end

  before '/casinos/delete' do
    role = User.by_id(session[:user_id])

    if request.request_method == 'POST' && (role.nil? || !role['write'])
      redirect back
    end
  end

  post '/casinos/delete' do
    #Deletes casino from db
    puts 'im here!'
    p params
    Casino.delete_by_id(params['id'])
    redirect '/'
  end

  before '/reviews' do
    role = User.by_id(session[:user_id])

    if request.request_method == 'POST' && (role.nil? || !role['write'])
      redirect back
    end
  end

  post '/reviews' do
    Review.new(params.values)

    Casino.set_rating(params['parent'], params['stars'])

    redirect back
  end

  post'/users' do
    #TODO Add response for wrong password or username
    user = User.check(params)

    if user != 0
      session[:user_id] = user
      redirect '/'
    else
      sleep(1)
      redirect '/users/failed'
    end
  end

  post '/users/new' do
    User.new(params)

    redirect '/users'
  end

  before '/users/edit' do
    role = User.by_id(session[:user_id])

    if role.nil? || !role['role_change']
      redirect back
    end
  end

  post '/users/edit' do
    User.edit(params)

    redirect back
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

end
