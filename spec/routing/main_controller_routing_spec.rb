# frozen_string_literal: true

require 'rails_helper'

describe 'MainController Routes' do
  %i[faq venues privacy about contact version].each do |endpoint|
    it "routes #{endpoint} to the main##{endpoint}" do
      expect(get: "/#{endpoint}").to route_to(controller: 'main', action: endpoint.to_s)
    end
  end
  it 'routes status to the main#status_page' do
    expect(get: '/status').to route_to(controller: 'main', action: 'status_page')
  end
end
