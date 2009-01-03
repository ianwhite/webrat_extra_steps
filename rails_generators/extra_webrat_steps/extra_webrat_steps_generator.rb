class ExtraWebratStepsGenerator < Rails::Generator::Base
   require 'yaml'
  
  def initialize(*args)
    
    # Added support for the languages cucumber comns with
    # 
    # Load a file languages.yml containing the translations
    # Get the language to use as arg
    # If no language is given, the generator works as usual
    
    @langs = YAML.load_file(File.dirname(__FILE__) + '/templates/languages.yml')
    @lang = args[0].to_s 
    if @lang then
      @features_path =  'features/' + @lang  
    else
      @features_path =  'features'
      @lang = 'en'  
    end
    
    File.exists?(@features_path + '/step_definitions/webrat_steps.rb') or raise "webrat_steps.rb not found, try running script/generate cucumber"
    @original_webrat_steps = File.read(@features_path + '/step_definitions/webrat_steps.rb')
    super(*args)
  end
  
  def manifest
    record do |m|
      m.directory File.join(@features_path + '/step_definitions')
      m.template 'webrat_extra_steps.rb', File.join(@features_path + '/step_definitions', "webrat_extra_steps.rb"),
        :assigns => {:scoped_methods => parse_scoped_methods}
    end
  end
  
protected
  def parse_scoped_methods
    methods = []
    @original_webrat_steps.scan(/\nWhen \/\^(.*?)\$\/ do \|(.*?)\|\n\s+(.+?)\s*\nend\n/m) do
      words = @langs['en'].merge(@langs[@lang])
      methods << "When /^#{words["within"]}: (.*?), #{$1}$/ do |scope, #{$2}|\n   within(scope) {|s| s.#{$3}}\nend"
    end
    methods
  end
end