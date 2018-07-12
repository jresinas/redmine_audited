	class AuditsController < ApplicationController
	menu_item :audited
	# before_filter :find_project_by_project_id, :only => [:show_project, :index_by_project, :show_by_project]
	# before_filter :authorize, :only => [:index, :show_project, :index_by_project, :show_by_project, :show_all]
	before_filter :find_project_by_project_id, :only => [:index_by_project, :show_by_project]
	before_filter :authorize, :only => [:index_by_project, :show_by_project]
	before_filter :authorize_global, :only => [:index, :show_all]
	before_filter :get_entity, :only => [:show_all, :show_by_project]

	def index
		@entities = ENTITIES #.map{|e| e[:model]}
		redirect_to :action => 'show_all', :entity => @entities.first[0] if @entities.count == 1
	end

	def index_by_project
		@entities = ENTITIES #.map{|e| e[:model]}
		redirect_to :action => 'show_by_project', :entity => @entities.first[0] if @entities.count == 1
	end

	def show_all
		@result = {}
		if @entity.present?
			entities_ids = Audited::Audit.where(auditable_type: @entity[:model].to_s).map(&:auditable_id)
			entities_ids += Audited::Audit.where(associated_type: @entity[:model].to_s).map(&:associated_id)
			entities_ids = entities_ids.uniq
			entities_ids.each do |entity_id|
				@result[entity_id] = {:name => (@entity[:model]).find(entity_id).audited_name, :data => []}
				
				entries = Audited::Audit.where("(auditable_type = ? AND auditable_id = ?) OR (associated_type = ? AND associated_id = ?)", @entity[:model].to_s, entity_id, @entity[:model].to_s, entity_id).order("created_at DESC").group_by(&:request_uuid)
				entries.each do |request, entry|
					date = entry.first.created_at
					user_id = entry.first.user_id
					if user_id.present?
						user = User.find(user_id)
						user = user.present? ? user.login : l(:"audited.label_unknown")
					else
						user = l(:"audited.label_unknown")
					end

					@result[entity_id][:data] << {:date => date, :user => user, :data => entry}
				end
			end
		end
	end

	# def show_project
	# 	@result = []
	# 	if @project.present?
	# 		entries = Audited::Audit.where("(auditable_type = ? AND auditable_id = ?) OR (associated_type = ? AND associated_id = ?)", "Project", @project.id, "Project", @project.id).order("created_at DESC").group_by(&:request_uuid)
	# 		entries.each do |request, entry|
	# 			date = entry.first.created_at
	# 			user_id = entry.first.user_id
	# 			if user_id.present?
	# 				user = User.find(user_id)
	# 				user = user.present? ? user.login : l(:"audited.label_unknown")
	# 			else
	# 				user = l(:"audited.label_unknown")
	# 			end

	# 			@result << {:date => date, :user => user, :data => entry}
	# 		end
	# 	end
	# end

	def show_by_project
		@result = {}
		if @project.present? and @entity.present?
			entries = Audited::Audit.where("auditable_type = ? OR associated_type = ?", @entity[:model].to_s, @entity[:model].to_s).order("created_at DESC")

			entries = entries.select{|e| 
				object = e.associated_id.present? ? e.associated : e.auditable
				@entity[:project].split(".").each do |m|
					object = object.send(m)
				end
				object == @project.id
			}

			entries.each do |e|
				element_id = e.associated_id.present? ? e.associated_id : e.auditable_id
				if @result[element_id].present?
					@result[element_id][:data] << e
				else
					@result[element_id] = {:name => (@entity[:model]).find(element_id).audited_name, :data => [e]}
				end
			end

			@result.each do |element, entries|
				new_data = {} 
				entries[:data].group_by(&:request_uuid).each do |request, entry|
					date = entry.first.created_at
					user_id = entry.first.user_id
					if user_id.present?
						user = User.find(user_id)
						user = user.present? ? user.login : l(:"audited.label_unknown")
					else
						user = l(:"audited.label_unknown")
					end

					if new_data.present? and new_data[request].present?
						new_data[request][:data] << entry
					else
						new_data[request] = [{:date => date, :user => user, :data => entry}]
					end
				end
				@result[element][:data] = new_data
			end			
		end
	end

	private
	def get_entity
		if params.present? and params[:entity].present?
			@entity = ENTITIES[params[:entity]]
		end
	end
end