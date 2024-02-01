require 'sqlite3'

class Seeder

    def self.seed!
        puts "Seeding the DB"
        drop_tables
        create_tables
        seed_data
        puts "Seed complete"
    end

    private

    def self.db
        return @db if @db
        @db = SQLite3::Database.new('db/db.sqlite')
        @db.results_as_hash = true
        return @db
    end

    def self.drop_tables
        puts "  * Dropping Tables"
        db.execute('DROP TABLE IF EXISTS movies')
    end
    
    
    def self.create_tables
        puts "  * Creating tables"
        db.execute('CREATE TABLE casinos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            win_stats INTEGER,
            turnover INTEGER,
            logo_filepath TEXT
        )')

        db.execute('CREATE TABLE casino_cats(
            id_casino INTEGER,
            id_cat INTEGER
        )')

        db.execute('CREATE TABLE cats(
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             name TEXT
        )')
    end
    
    def self.seed_data
        puts "  * Seeding tables"

        casinos = [
            {name: 'Hippity Hoppity money gone', win_stats: '0.92', turnover: '2', logo_filepath: 'public/img/casino'},
        ]

        casinos.each do |casino|
            db.execute('INSERT INTO casinos (name, win_stats, turnover, logo_filepath) VALUES (?,?,?,?)', casino[:name], casino[:win_stats], casino[:turnover], casino[:logo_filepath])
        end
    end
end
