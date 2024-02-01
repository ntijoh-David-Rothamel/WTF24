class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get '/' do
      redirect '/users'
    end

    get '/users' do
      erb :'users/index'
    end

    get '/users/new' do
      erb :'users/signin'
    end
    
    
end