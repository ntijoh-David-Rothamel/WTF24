class App < Sinatra::Base
  require '../src/db/seed'

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
      redirect '/casinos'
    end

    get '/casinos' do
      erb :'casinos/index'
    end

    get '/users' do
      erb :'users/index'
    end

    get '/users/new' do
      erb :'users/signin'
    end
    
    get '/seed' do
      Seeder.seed!
      redirect '/users'
    end
end