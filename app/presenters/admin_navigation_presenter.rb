class AdminNavigationPresenter

  attr_reader :current_user

  def initialize(view_context, user)
    @view_context = view_context
    @current_user = user
  end
                 
  def links
    manager_links = [[:studios , {}]]
    editor_links = [[:events, {}],
                    [:featured_artist , {}],
                    [:cms_documents , {:display => 'cms', :link => '/cms_documents'}]
                   ]
    if current_user.is_admin?
      pr_links = [
                  [:events, {}],
                  [:featured_artist, {}],
                  [:favorites, {}],
                  [:catalog, {:link => '/catalog'}],
                  [:cms_documents , {:display => 'cms', :link => '/cms_documents'}]
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
                     [:roles , {:link => '/roles'}],
                     [:internal_email , {:display => 'internal messaging', :link => @view_context.admin_email_lists_path }],
                     [:db_backups , {:display => 'backups'}],
                     [:blacklist, {:display => 'blacklist', :link => '/blacklist_domains'}],
                     [:os_status , {}]
                    ]
      internal_links = [
                        [:palette , {:display => 'colors'}],
                        [:app_events, {:display => 'app events', :link => @view_context.admin_application_events_path}],
                        [:tests , {:link => '/tests'}]
                       ]
      links =[
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
