require 'byebug'

class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) {
        instance_variable_get("@#{name}")
      }

      name_with_equals = "#{name}=".to_sym

      define_method(name_with_equals) { |value|
        instance_variable_set("@#{name}", value)
      }
    end
  end
end
