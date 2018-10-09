require 'sqlite3'

class SQLLiteDatabaseProvider < AbstractSQLDatabaseProvider
  attr_accessor :database

  def connect
    @database = SQLite3::Database.new 'data/db.db'
    @database.results_as_hash = true
  end

  def query(sql = '', bind_vars = [], *args, &block)
    @database.execute(sql, bind_vars, args, &block)
  end
end