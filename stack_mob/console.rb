require 'rubygems'
require 'oauth'
require "json"
require 'readline'

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
      @schema_hash = nil
    end
    
    def run
      puts "Welcome to the Stackmob Console. Press ctrl-C or type 'exit' to quit"
      while line = Readline.readline('stackmob> ', true)
        begin
          puts self.process(line).call
        rescue SystemExit => e
          exit
        rescue Exception => e
          puts "error: #{e}"
        end
      end
    end
    
    def get_full_schema
      @schema_hash = @client.get('listapi') if @schema_hash == nil
      @schema_hash
    end
    
    def error_proc(msg)
      Proc.new {
        "error: #{msg}"
      }
    end
    
    def json_proc(hash)
      Proc.new {
        JSON.pretty_generate(hash)
      }
    end
        
    def process(str)
      str_split = str.split(' ')
      return error_proc("unrecognized command #{cmd}") if str_split.count < 1
      cmd = str_split[0]
      
      case cmd.downcase
      when "exit"
        Proc.new {
          puts "bye"
          exit
        }
      when "listapi"
        @schema_hash = @client.get('listapi')
        json_proc @schema_hash
      when "getall"
        return error_proc("model name required") if str_split.count != 2
        model_name = str_split[1]
        #TODO: check for shitloads of objects and warn if too many
        json_proc(@client.get(model_name, :model_id => :all))
      when "method"
        return error_proc("usage: method <method_name> <json (optional)>") if str_split.count < 2
        method_name = str_split[1]
        json = "{}"
        json = str_split.drop(2).join(" ") if str_split.count >= 3
        begin
          parsed = JSON.parse(json)
        rescue
          return error_proc("invalid json #{json}")
        end
        json_proc(@client.get(method_name, :json => json))
      else
        Proc.new { puts "unrecognized command #{cmd}"}
      end
    end
  end
end