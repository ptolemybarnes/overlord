require 'pry'

module Overlord
  module ClassMethods
    def method_added(method_name)
      method = instance_method(method_name)
      parameters = method.parameters

      # assumes all-or-nothing with keyword parameters
      args_key = parameters.any? { |key, name| key === :keyreq } ?
        parameters.flat_map(&:last).sort :
        method.arity

      return if method.arity < 0
      undef_method method_name
      overloaded_methods[[method_name, args_key]] = method

      define_method(method_name) do |*args|
        if args.first.is_a?(Hash)
          args_key = args.flat_map(&:keys).sort
          error_message = "keywords: #{args.flat_map(&:keys).join(', ')}"
        else
          args_key = args.size
          error_message = "arity #{args.size}"
        end
        method = self.class.overloaded_methods[[method_name, args_key]]
        raise NoMethodError.new("undefined method `#{method_name}` with #{error_message}") unless method
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
