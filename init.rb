require 'audited/custom_value_patch'
require 'audited/entities_patches'

Dir["#{File.dirname(__FILE__)}/config/initializers/**/*.rb"].sort.each do |initializer|
 require initializer
end

Redmine::Plugin.register :redmine_audited do
  name 'Audited Plugin'
  author 'jresinas'
  description ''
  version '0.0.1'
  author_url 'http://www.emergya.es'

  project_module :audition do
    # permission :audition, { :audits => [:index, :show_all, :show_project, :index_by_project, :show_by_project] }
    permission :audition, { :audits => [:index, :show_all, :index_by_project, :show_by_project] }
  end

  menu :top_menu, :audited, { :controller => 'audits', :action => 'index' },
       :caption => :"audited.label_audit",
       :if => Proc.new { User.current.allowed_to?(:audition, nil, :global => true) }

  menu :project_menu, :audited, { :controller => 'audits', :action => 'index_by_project' },
       :caption => :"audited.label_audit",
       :param => :project_id
end