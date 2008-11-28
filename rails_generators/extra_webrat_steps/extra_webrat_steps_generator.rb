class ExtraWebratStepsGenerator < Rails::Generator::Base
  def initialize(*args)
    super(*args)
    File.exists?('features/step_definitions/webrat_steps.rb') or raise "webrat_steps.rb not found, try running script/generate cucumber"
    @original_webrat_steps = File.read('features/step_definitions/webrat_steps.rb')
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      m.template 'webrat_extra_steps.rb', File.join('features/step_definitions', "webrat_extra_steps.rb"),
        :assigns => {:scoped_methods => parse_scoped_methods}
    end
  end
  
protected
  def parse_scoped_methods
    methods = []
    @original_webrat_steps.scan(/\nWhen \/\^(.*?)\$\/ do \|(.*?)\|\n\s+(.+?)\s*\nend\n/m) do
      methods << "When /^within: (.*?), #{$1}$/ do |scope, #{$2}|\n   within(scope) {|s| s.#{$3}}\nend"
    end
    methods
  end
end