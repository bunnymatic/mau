class ScssColorReader

  def initialize(file)
    @scss_file = file
  end

  class SassVariableEvaluator < Sass::Tree::Visitors::Base
    def visit_variable(node)
      @environment ||= Sass::Environment.new
      begin
        val = node.expr.perform(@environment)
      rescue Sass::SyntaxError
        val = node.expr
      end
      @environment.set_local_var(node.name, val)
      [node.name, node.expr.perform(@environment)]
    end
  end

  def parse_colors
    engine = Sass::Engine.for_file(@scss_file, syntax: :scss)
    colors = SassVariableEvaluator.visit(engine.to_tree).compact.reject{|entry| entry.flatten.empty?}
    colors.map{|name, color| [ name, color.to_s.gsub(/^#/,'') ]}
  end

end
