DESTINATION_DIR = Rails.root.join('app/webpack/reactjs/components')

class ReactComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_react_component
    template 'component.tsx.erb', DESTINATION_DIR.join("#{file_name}.tsx")
    template 'component.test.tsx.erb', DESTINATION_DIR.join("#{file_name}.test.tsx")
  end
end
