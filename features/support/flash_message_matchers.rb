# frozen_string_literal: true

RSpec::Matchers.define :have_flash do |kind, msg|
  def flash_class(kind)
    ".flash.flash__#{kind}"
  end

  match do
    wait_until do
      !page.all(flash_class(kind)).empty?
    end

    expect(page).to have_css(flash_class(kind).to_s, text: msg)
  end

  failure_message_for_should do |actual|
    "expected #{actual.body} to have a #{kind} flash message with text #{msg}"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual.body} not to have a #{kind} flash message with text #{msg}"
  end
end
