require 'mysql2'

class MYSQLDatabaseProvider < AbstractSQLDatabaseProvider
  attr_accessor :client

  def connect
    @client = Mysql2::Client.new(:host => '127.0.0.1',
                                 :port => 3306,
                                 :username => 'username',
                                 :password => 'password',
                                 :database => 'linkedin_stats')
  end

  def query(sql = '', bind_vars = [], *args, &block)
    statement = @client.prepare(sql)
    result = if bind_vars.count > 0
               statement.execute(*bind_vars)
             else
               statement.execute
             end

    if block_given?
      result.each do |row|
        yield row
      end
    else
      result.to_a
    end
  end
end