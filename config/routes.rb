 match '/audit' => 'audits#index', via: [:get, :post, :put, :patch]
 match '/projects/:project_id/audit' => 'audits#index_by_project', via: [:get, :post, :put, :patch]
 match '/show_all/:entity' => 'audits#show_all', via: [:get, :post, :put, :patch], :as => 'show_all_entity'
 match '/projects/:project_id/audit/:entity' => 'audits#show_by_project', via: [:get, :post, :put, :patch], :as => 'show_by_project_entity'
 # match '/projects/:project_id/audit' => 'audits#show_project', via: [:get, :post, :put, :patch], :as => 'show_project'
