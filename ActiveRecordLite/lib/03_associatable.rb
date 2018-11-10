require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    options.has_key?(:primary_key) ? @primary_key = options[:primary_key] : @primary_key = :id
    options.has_key?(:foreign_key) ? @foreign_key = options[:foreign_key] : @foreign_key = "#{name}_id".to_sym
    options.has_key?(:class_name) ? @class_name = options[:class_name] : @class_name = name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    @self_class_name = self_class_name
    options.has_key?(:primary_key) ? @primary_key = options[:primary_key] : @primary_key = :id
    options.has_key?(:foreign_key) ? @foreign_key = options[:foreign_key] : @foreign_key = "#{self_class_name.underscore}_id".to_sym
    options.has_key?(:class_name) ? @class_name = options[:class_name] : @class_name = name.to_s.singularize.camelcase
  end
end

module Associatable
  # Phase IIIb

  # Begin writing a belongs_to method for Associatable. This method should take
  # in the association name and an options hash. It should build a BelongsToOptions
  # object; save this in a local variable named options.
  #
  # Within belongs_to, call define_method to create a new method to access the association. Within this method:
  #
  # Use send to get the value of the foreign key.
  # Use model_class to get the target model class.
  # Use where to select those models where the primary_key column is equal to the foreign key value.
  # Call first (since there should be only one such item).
  # Throughout this method definition, use the options object so that defaults are used appropriately.
  #
  # Do likewise for has_many.

# continue here next time

  def belongs_to(name, options = {})

    options = BelongsToOptions.new(name, options)
    # debugger

    # options = #<BelongsToOptions:0x007f9552554940
    # @name=:human, @primary_key=:id, @foreign_key=:owner_id, @class_name="Human">

    # self = Cat class

    # We want Cat.human to return the correct human
    define_method(name) do
    # define_method(name) do |options|
      #now in a cat instance
      # debugger
      query_table = options.model_class # "Humans"
      query_table.where({options.primary_key => self.send(options.foreign_key)})
    end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
