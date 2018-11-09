require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # schema = DBConnection.execute(<<-SQL
    #   PRAGMA table_info('#{self.table_name}');
    # SQL
    # )
    @columns ||=
      (DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          '#{self.table_name}';
      SQL
      )[0].map {|col| col.to_sym}
  end

  def self.finalize!
  end



  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.table_name=(table_name)
    table_name.nil? ? self.table_name : @table_name = table_name
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(table_name, columns, params = {})
    @table_name = table_name
    @columns = columns
  end

  def attributes
    # ...
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
