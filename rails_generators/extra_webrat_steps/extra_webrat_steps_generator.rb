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
    
    # remove 'When I go to' as that doesn't make sense to be scoped
    @original_webrat_steps.sub(/\nWhen \/\^I go to.*?\nend\n/,'')
    
    # create scoped method variants of all of the 'When' steps
    @original_webrat_steps.scan(/\nWhen \/\^(.*?)\$\/ do \|(.*?)\|\n\s+(.+?)\s*\nend\n/m) do
      methods << "When /^within: (.*?), #{$1}$/ do |scope, #{$2}|\n  within(scope) {|s| s.#{$3}}\nend"
    end
    
    # add scoped versions of 'I should see' steps
    methods << "Then /^within: (.*?), I should see \"(.*)\"$/ do |scope, text|\n" +
               "  within(scope) {|s| s.dom.should contain(text)}\n" +
               "end"
    methods << "Then /^within: (.*?), I should not see \"(.*)\"$/ do |scope, text|\n" +
               "  within(scope) {|s| s.dom.should_not contain(text)}\n" +
               "end"
    methods
  end
end