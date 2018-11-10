require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||=
      (DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name};
      SQL
      )[0].map {|col| col.to_sym}
  end

  # Alternate way to grab table columns (without parsing)
  # schema = DBConnection.execute(<<-SQL
  #   PRAGMA table_info('#{self.table_name}');
  # SQL
  # )

  def self.finalize!
    self.columns.each do |col|
      define_method(col) {
        attributes[col]
      }

      name_with_equals = "#{col}=".to_sym

      define_method(name_with_equals) do |value|
        attributes[col] = value
      end
    end

  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.table_name=(table_name)
    table_name.nil? ? self.table_name : @table_name = table_name
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name};
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    data = []
    results.each do |datum|
      data << self.new(params = datum)
    end
    data
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?;
    SQL
    result.empty? ? nil : self.parse_all(result)[0]
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute '#{k}'" unless respond_to?("#{k}=".to_sym)
      send("#{k}=",v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    columns = self.class.columns - [:id]
    col_str = columns.map {|el| el.to_s}.join(", ")
    qmark_str = (["?"] * columns.length).join(", ")
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_str})
        VALUES
          (#{qmark_str});
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    columns = self.class.columns - [:id]
    attr_values = attribute_values[1..-1] + [attribute_values[0]]
    set_str = columns.map {|el| "#{el} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, attr_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_str}
      WHERE
        id = ?;
    SQL
  end

  def save
    self.class.find(self.id) ? update : insert
  end
end
