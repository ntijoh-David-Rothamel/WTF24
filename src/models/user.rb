# frozen_string_literal: true

module User
  enable :sessions

  def self.all_users
    user_query = "
    SELECT * FROM users
    LEFT JOIN users_roles ON users.id = users_roles.user_id
    LEFT JOIN roles ON users_roles.role_id = roles.id"

    db.execute(user_query)
  end

  def self.by_session_id
    check_session

    query = '
    SELECT * FROM users
    LEFT JOIN users_roles ON users.id = users_roles.user_id
    LEFT JOIN roles ON users_roles.role_id = roles.id
    WHERE users.id=?'

    db.execute(query, session[:user_id]).first
  end

  def self.all_roles
    db.execute('SELECT * FROM roles')
  end

  def check_session
    if session[:user_id].nil?
      session[:user_id] = 0
    end
  end

  def db
    if db.nil?
      db = SQLite3::Database.new('./db/db.sqlite')
      db.results_as_hash = true
    end
    return db
  end
end
