require 'rails_helper'

describe MarkdownService do
  it "converts markdown to html" do
    marked_down = MarkdownService.markdown("# one\n## two")
    expect(marked_down).to include "<h1>one</h1>"
    expect(marked_down).to include "<h2>two</h2>"
  end

  it "removes script tags" do
    marked_down = MarkdownService.markdown("# one\n<h2>two</h2><script>alert('yo');</script>")
    expect(marked_down).to include "<h1>one</h1>"
    expect(marked_down).to include "<h2>two</h2>"
    expect(marked_down).to_not include "script"
  end
end
