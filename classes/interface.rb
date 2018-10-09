# Hacky interface implementation
module Interface
  class InterfaceNotImplementedError < NoMethodError
  end

  def self.included(cls)
    cls.send(:include, Interface::Methods)
    cls.send(:extend, Interface::Methods)
  end

  module Methods

    def api_not_implemented(cls)
      caller.first.match(/in '(.+)'/)
      method_name = $1
      raise Interface::InterfaceNotImplementedError.new("#{cls.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end
  end
end