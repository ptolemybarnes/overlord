require 'pry'

module Overlord
  INCLUDED = Proc.new do |method_name|
    @overloaded_methods ||= Hash.new
    method = instance_method(method_name)
    return if method.arity < 0
    undef_method method_name
    @overloaded_methods[[method_name, method.arity].hash] = method

    overloaded_methods = @overloaded_methods

    define_method(method_name) do |*args|
      method = overloaded_methods[[method_name, args.size].hash]
      raise NoMethodError.new("undefined method `#{method_name}` with arity #{args.size}") unless method
      method.bind(self).call(*args)
    end
  end

  def self.included(klass)
    klass.define_singleton_method(:method_added, &INCLUDED)
  end
end
