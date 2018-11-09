require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

# haskell_cats = Cat.where(:name => "Haskell", :color => "calico")
# # SELECT
# #   *
# # FROM
# #   cats
# # WHERE
# #   name = ? AND color = ?
# I used a local variable where_line where I mapped the keys of the params to "#{key} = ?" and joined with AND.
#
# To fill in the question marks, I used the values of the params object.

module Searchable
  def where(params)
    if params.length == 1
      where_str = params.map {|k, v| "#{k} = ?"}[0]
    else
      where_str = params.map {|k, v| "#{k} = ?"}.join(" AND ")
    end
    results = DBConnection.execute(<<-SQL, params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_str};
    SQL
    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
