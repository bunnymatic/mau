require 'spec_helper'

describe RolesUser do
  fixtures :roles, :users, :roles_users

  subject { role_user }

  context 'for a manager' do
    let(:role_user) { roles_users(:artist1_manager) }
    its(:is_manager_role?) { should be_true }
  end

  context 'for an admin' do
    let(:role_user) { roles_users(:admin_admin) }
    its(:is_manager_role?) { should be_false }
  end

  context 'for an editor' do
    let(:role_user) { roles_users(:quentin_editor) }
    its(:is_manager_role?) { should be_false }
  end

end
