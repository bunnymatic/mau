# frozen_string_literal: true
require 'rails_helper'
describe RolesController do
  let(:editor) { FactoryBot.create(:artist, :editor, :active) }
  let(:manager) { FactoryBot.create(:artist, :manager, :active) }
  let(:admin) { FactoryBot.create(:artist, :admin, :active) }
  let(:artist) { FactoryBot.create(:artist, :active) }

  let!(:users) { [editor, manager, admin] }
  let(:manager_role) { manager.roles.first }
  let(:editor_role) { editor.roles.first }
  let(:admin_role) { admin.roles.first }

  describe '#destroy' do
    before do
      login_as admin
    end
    context 'with role and user' do
      it 'removes the role association from the user' do
        expect do
          delete :destroy, params: { user_id: editor.id, id: editor_role.id }
        end.to change(editor.roles, :count).by(-1)
      end
      it 'redirects to the role page' do
        delete :destroy, params: { user_id: editor.id, id: editor_role.id }
        expect(response).to redirect_to admin_role_path(editor_role)
      end
    end
    context 'with invalid role and user' do
      it 'removes the role association from the user' do
        expect do
          delete :destroy, params: { user_id: 'bogus', id: editor_role.id }
        end.to change(editor.roles, :count).by(0)
      end
      it 'redirects to the role page' do
        delete :destroy, params: { user_id: 'bogus', id: editor_role.id }
        expect(response).to redirect_to admin_role_path(editor_role)
        expect(flash[:error]).to be_present
      end
    end
  end
end
