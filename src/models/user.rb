# frozen_string_literal: true

module User
  def self.new(params)
    query = '
    INSERT INTO users
    (username, password, email)
    VALUES (?,?,?)
    RETURNING id'

    password = BCrypt::Password.create(params['password'])

    user_id = db.execute(query, params['username'], password, params['email']).first

    new_role_user(user_id)
  end

  def self.edit(params)
    query_role = '
    SELECT id FROM roles
    WHERE rolename=?'

    query_user_role = '
    UPDATE users_roles
    SET role_id=?
    WHERE user_id=?'

    params.each do |role|
      role_id = db.execute(query_role, role[1]).first
      db.execute(query_user_role, role_id['id'], role[0])
    end
  end

  def self.all_users
    user_query = "
    SELECT * FROM users
    LEFT JOIN users_roles ON users.id = users_roles.user_id
    LEFT JOIN roles ON users_roles.role_id = roles.id"

    db.execute(user_query)
  end

  def self.check(params)
    query = '
    SELECT * FROM users
    WHERE username = ?'

    begin
      user = db.execute(query, params['username']).first
    rescue SQLException::ConstraintException
      puts 'wrong username'
      return 0
    end

    #TODO Add cooldown for bruteforce
    #TODO Solve session cannot be in models
    # Varför för i helvete spelar det roll i vilken ordning den jäkla jämförelsen sker?
    if BCrypt::Password.new(user['password']) == params['password']
      puts 'works in mysterious ways'
      return user['id']
    else
      puts 'wrong password'
      p params['password']
      p BCrypt::Password.new(user['password'])
      p user['password']
      return 0
    end
  end

  def self.by_id(id)
    query = '
    SELECT * FROM users
    LEFT JOIN users_roles ON users.id = users_roles.user_id
    LEFT JOIN roles ON users_roles.role_id = roles.id
    WHERE users.id=?'

    p id

    db.execute(query, id).first
  end

  def self.all_roles
    db.execute('SELECT * FROM roles')
  end

  def self.new_role_user(user_id)
    query = '
    INSERT INTO users_roles
    (user_id, role_id)
    VALUES (?,?)'

    db.execute(query, user_id[0], 4)
  end

  def self.db
    if @db.nil?
      @db = SQLite3::Database.new('./db/db.sqlite')
      @db.results_as_hash = true
    end
    return @db
  end
end
