module Audited
  module CustomValuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        audited associated_with: :customized
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end


ActionDispatch::Callbacks.to_prepare do
  CustomValue.send(:include, Audited::CustomValuePatch)
end
