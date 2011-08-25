require 'rubygems'
require 'oauth'
require "json"

module StackMob
  class Console
    #this is copied from StackMob::Oauth. really should be factored into common superclass
    def initialize(stackmob_client)
      @client = stackmob_client
      @listapi = @client.get 'listapi'
      #TODO: represent all the data models as ruby objects somehow. possibly do code generation (I think that's what ActiveRecord does)?
      #code gen might not be too tough for the crud methods, given that it would be much easier to create a single class that can understand any schema
      #and automatically provide the crud methods with type checking. then, code generation would simply be a matter of generating a class for each of the models
      #and having that class subclass the superclass, passing in its schema.
      #
      #alternative is to just parse ruby commands with regexes. would get the job done for now, unsure about sustainability
    end
    
    def process(cmd)
      case cmd.downcase
        when "exit"
          Proc.new { sys.exit }
        end
        #TODO: everything else!
      end
    end
  end
end