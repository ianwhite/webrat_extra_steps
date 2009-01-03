require 'yaml'

class ExtraWebratStepsGenerator < Rails::Generator::Base
  def initialize(args, options)
    @features_path = 'features'
    set_language(args.first)
    unless File.exists?(webrat_steps = File.join(@features_path, 'step_definitions', 'webrat_steps.rb'))
      raise "#{webrat_steps} not found, try running script/generate cucumber, or changing language"
    end
    @original_webrat_steps = File.read(File.join(@features_path, "step_definitions/webrat_steps.rb"))
    super(args, options)
  end
  
  def manifest
    record do |m|
      m.directory File.join(@features_path, 'step_definitions')
      m.template 'webrat_extra_steps.rb', File.join(@features_path, 'step_definitions', "webrat_extra_steps.rb"),
        :assigns => {:scoped_methods => parse_scoped_methods, :features_path => @features_path, :language => @language}
    end
  end
  
protected
  def parse_scoped_methods
    methods = []
    @original_webrat_steps.scan(/\nWhen \/\^(.*?)\$\/ do \|(.*?)\|\n\s+(.+?)\s*\nend\n/m) do
      methods << "When /^#{@translations["within"]}: (.*?), #{$1}$/ do |scope, #{$2}|\n   within(scope) {|s| s.#{$3}}\nend"
    end
    methods
  end
  
  # Load up the transations for the passed language, and modify the features_path accordingly
  def set_language(language)
    @language = language
    languages = YAML.load_file(File.join(File.dirname(__FILE__), 'templates/languages.yml'))
    @features_path = File.join(@features_path, @language) if @language
    @translations = languages['en']
    @translations.merge!(languages[@language]) if @language
  end
end