class AbstractSQLDatabaseProvider
  include Interface

  def connect
    AbstractSQLDatabaseProvider.api_not_implemented(self)
  end

  def query(sql = '', bind_vars = [], *args, &block)
    AbstractSQLDatabaseProvider.api_not_implemented(self)
  end

end