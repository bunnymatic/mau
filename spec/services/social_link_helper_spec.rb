require 'rails_helper'

describe SocialLinkHelper do
  describe '#handle' do
    [
      %w[http://instagram.com/katgeng katgeng],
      %w[https://instagram.com/brandmia/ brandmia],
      %w[http://instagram.com/caitlinwinner caitlinwinner],
      %w[https://www.instagram.com/aynurgirginwesten/ aynurgirginwesten],
      %w[http://instagram.com/jon-levy-warren jon-levy-warren],
    ].each do |(link, expected_handle)|
      it "finds the handle '#{expected_handle} from '#{link}'" do
        extracted_handle = described_class.new(link).handle
        expect(extracted_handle).to eq expected_handle
      end
    end

    %w[
      http://iriswillow
      http://@enlightenmentbarbie
      iriswillow
      @enlightenmentbarbie
    ].each do |link|
      it "does not find a handle from '#{link}'" do
        expect(described_class.new(link).handle).to be_nil
      end
    end
  end
end
