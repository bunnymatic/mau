require 'rails_helper'

describe MarkdownService do
  it "converts markdown to html" do
    marked_down = MarkdownService.markdown("# one\n## two")
    expect(marked_down).to include "<h1>one</h1>"
    expect(marked_down).to include "<h2>two</h2>"
  end

  it "filters script tags" do
    marked_down = MarkdownService.markdown("# one\n<script>alert('yo')</script>")
    expect(marked_down).to include "<h1>one</h1>"
    expect(marked_down).to_not include "script"
  end

  it "strips leading spaces from the full doc (not every line)" do
    marked_down = MarkdownService.markdown("               this will not have pre code\n\n     and this will")
    expect(marked_down).to include "<p>this will not"
    expect(marked_down).to include "<pre><code> and this will"
  end

end
