class AdminNavigation < ViewPresenter

  attr_reader :current_user

  def initialize(user)
    @current_user = user
  end

  def links
    manager_links = [[:studios , {}]]
    editor_links = [[:events, {}],
                    [:featured_artist , {}],
                    [:cms_documents , {:display => 'cms', :link => url_helpers.admin_cms_documents_path}]
                   ]
    if current_user.is_admin?
      pr_links = [
                  [:events, {}],
                  [:featured_artist, {}],
                  [:favorites, {}],
                  [:catalog, {:link => '/catalog'}],
                  [:cms_documents , {:display => 'cms', :link => url_helpers.admin_cms_documents_path}]
                 ]
      model_links = [
                     [:artists , {}],
                     [:fans , {}],
                     [:studios , {}],
                     [:media , {}],
                     [:art_piece_tags , {:display => 'tags'}],
                     [:artist_feeds , {:display => 'feeds'}],
                     [:emaillist , {:display => 'emails'}]
                    ]
      admin_links = [
                     [:open_studios_events , {:display => 'os dates'}],
                     [:roles, {}],
                     [:internal_email , {:display => 'admin email lists', :link => url_helpers.admin_email_lists_path }],
                     [:db_backups , {:display => 'backups'}],
                     [:blacklist, {:display => 'blacklist', :link => url_helpers.admin_blacklist_domains_path}],
                     [:os_status , {}]
                    ]
      internal_links = [
                        [:palette , {:display => 'colors'}],
                        [:app_events, {:display => 'app events', :link => url_helpers.admin_application_events_path}],
                        [:tests , {:link => url_helpers.admin_tests_path}]
                       ]
      links = [
               [:models, model_links],
               [:pr, pr_links],
               [:admin, admin_links],
               [:internal, internal_links]
              ]
    else
      links = []
      links << [nil, editor_links] if current_user.is_editor?
      links << [nil, manager_links] if current_user.is_manager?
    end
    links.each do |sxn, entries|
      entries.each do |key, entry|
        entry[:display] = (entry[:display] || key.to_s).tr("_", ' ')
        entry[:link] = entry[:link] || ("/admin/%s" % key)
      end
    end
  end
end
