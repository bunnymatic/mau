require 'rails_helper'

describe ApplicationHelper do
  describe '#react_component' do
    let(:options) { {} }
    let(:id) { 'element-id' }
    let(:component) { 'AReactComponent' }

    it 'renders with minimal arguments' do
      rendered = helper.react_component(id:, component:)
      expect(rendered).to have_css('div#element-id.react-component')
      node = Nokogiri::HTML::DocumentFragment.parse(rendered).css('div')
      expect(node.attribute('data-component').value).to eq 'AReactComponent'
      expect(node.attribute('data-react-props').value).to eq JSON.generate({})
    end

    it 'renders with props' do
      props = { prop1: 'prop1 value', prop2: 'other prop' }
      rendered = helper.react_component(id:, component:, props:)
      expect(rendered).to have_css('div#element-id.react-component')
      node = Nokogiri::HTML::DocumentFragment.parse(rendered).css('div')
      expect(node.attribute('data-component').value).to eq 'AReactComponent'
      expect(node.attribute('data-react-props').value).to eq JSON.generate(props)
    end

    it 'camelizes props keys' do
      props = { snake_case: { other_thing: 'here' } }
      rendered = helper.react_component(id:, component:, props:)
      expect(rendered).to have_css('div#element-id.react-component')
      node = Nokogiri::HTML::DocumentFragment.parse(rendered).css('div')
      expect(node.attribute('data-component').value).to eq 'AReactComponent'
      expect(node.attribute('data-react-props').value)
        .to eq JSON.generate({
                               snakeCase: { otherThing: 'here' },
                             })
    end

    it 'renders with a custom wrapper tag' do
      rendered = helper.react_component(id:, component:, wrapper_tag: 'span')
      expect(rendered).to have_css('span#element-id.react-component')
      node = Nokogiri::HTML::DocumentFragment.parse(rendered).css('span')
      expect(node.attribute('data-component').value).to eq 'AReactComponent'
      expect(node.attribute('data-react-props').value).to eq JSON.generate({})
    end

    it 'renders with a custom wrapper tag and props' do
      props = { 'abc' => 'whatever' }
      rendered = helper.react_component(id:, component:, wrapper_tag: 'a', props:)
      expect(rendered).to have_css('a#element-id.react-component')
      node = Nokogiri::HTML::DocumentFragment.parse(rendered).css('a')
      expect(node.attribute('data-component').value).to eq 'AReactComponent'
      expect(node.attribute('data-react-props').value).to eq JSON.generate(props)
    end
  end
end
