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
    body = CGI.unescapeHTML(email.html_part.to_s)
    if @expected_text.is_a?(String)
      @given_text = body.gsub(/\s+/, ' ')
      @expected_text = @expected_text.gsub(/\s+/, ' ')
      @given_text.include?(@expected_text)
    else
      @given_text = body
      !!(@given_text =~ @expected_text)
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

def have_body_text(text)
  HaveBodyText.new(text)
end

class HaveLinkInBody
  def initialize(expected_link_text, href:)
    @expected_link_text = expected_link_text
    @expected_link_url = href
  end

  def description
    desc = "have link #{@expected_link_text.inspect}"
    return desc if @expected_link_url.nil?

    desc + " (#{@expected_link_url})"
  end

  def matches?(email)
    @given_text = email.html_part.to_s
    html = Capybara::Node::Simple.new(email.html_part.to_s)
    if @expected_link_url.nil?
      html.has_link?(@expected_link_text)
    else
      html.has_link?(@expected_link_text, href: @expected_link_url)
    end
  end

  def failure_message
    "expected to find link #{@expected_link_text.inspect} in #{@given_text}"
  end

  def failure_message_when_negated
    "expected not to find link #{@expected_link_text.inspect} in #{@given_text}"
  end

  alias negative_failure_message failure_message_when_negated
end

def have_link_in_body(link, href: nil)
  HaveLinkInBody.new(link, href:)
end
