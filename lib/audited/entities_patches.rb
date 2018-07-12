ActionDispatch::Callbacks.to_prepare do
	ENTITIES.each do |name_entity, entity|

		module Audited
			def self.included(base)
		      base.class_eval do
		        audited
		      end
		    end
		end

		module HasAssociatedAudits
			def self.included(base)
		      base.class_eval do
		        has_associated_audits
		      end
		    end
		end

	  	(entity[:model]).send(:include, Audited)
	  	(entity[:model]).send(:include, HasAssociatedAudits) if entity[:custom_fields]
	  	(entity[:model]).send(:define_method, :audited_name) do
	  		return eval(entity[:name])
	  	end
	end
end