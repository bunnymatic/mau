# frozen_string_literal: true
class HaveBodyText
  def initialize(expected_text)
    @expected_text = expected_text
  end

  def description
    if @expected_text.is_a?(String)
      "have body including #{@expected_text.inspect}"
    else
      "have body matching #{@expected_text.inspect}"
    end
  end

  def matches?(email)
    [ email.html_part.to_s, email.text_part.to_s ].all? do |body|
      if @expected_text.is_a?(String)
        @given_text = body.to_s.gsub(/\s+/, " ")
        @expected_text = @expected_text.gsub(/\s+/, " ")
        @given_text.include?(@expected_text)
      else
        @given_text = body.to_s
        !!(@given_text =~ @expected_text)
      end
    end
  end

  def failure_message
    if @expected_text.is_a?(String)
      "expected the body to contain #{@expected_text.inspect} but was #{@given_text.inspect}"
    else
      "expected the body to match #{@expected_text.inspect}, but did not.  Actual body was: #{@given_text.inspect}"
    end
  end

  def failure_message_when_negated
    if @expected_text.is_a?(String)
      "expected the body not to contain #{@expected_text.inspect} but was #{@given_text.inspect}"
    else
      "expected the body not to match #{@expected_text.inspect} but #{@given_text.inspect} does match it."
    end
  end
  alias negative_failure_message failure_message_when_negated
end

def have_body_text(txt)
  HaveBodyText.new(txt)
end
