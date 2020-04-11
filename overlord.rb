require 'pry'

module Overlord
  module ClassMethods
    def method_added(method_name)
      method = instance_method(method_name)
      return if method.arity < 0
      undef_method method_name
      overloaded_methods[[method_name, method.arity].hash] = method

      define_method(method_name) do |*args|
        method = self.class.overloaded_methods[[method_name, args.size].hash]
        raise NoMethodError.new("undefined method `#{method_name}` with arity #{args.size}") unless method
        method.bind(self).call(*args)
      end
    end

    def overloaded_methods
      @overloaded_methods ||= {}
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end
end
