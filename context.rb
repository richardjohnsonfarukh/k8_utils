#!/usr/bin/ruby

require "tty-command"
require "tty-prompt"
require "pastel"
require "optparse"

@prompt = TTY::Prompt.new(interrupt: :exit)
@cmd = TTY::Command.new(printer: TTY::Command::Printers::Null)
@pastel = Pastel.new
START = @pastel.green.bold("$")
DONE =  "#{@pastel.blue.bold("!")} Done."


def select_context()
   contexts, err = @cmd.run("kubectl config get-contexts -o name")
   contexts = contexts.split("\n")
   question = "#{START} Select context:"

   return @prompt.select(question, contexts, cycle: true, filter: true)
end

def set_context(context)
   @cmd.run("kubectl config use-context #{context}")
end

def get_current_context()
   current_context, err = @cmd.run("kubectl config current-context")
   puts "#{START} Current context is #{@pastel.bold(current_context)}"
   return current_context.strip
end

def set_namespace_for_context(namespace, context="--current")
   @cmd.run("kubectl config set-context #{context} --namespace=#{namespace}")
end

def select_namespace(context)
   namespaces, err = @cmd.run("kubectl --context=#{context} get namespaces -o name | cut -c 11-")
   namespaces = namespaces.split("\n")
   question = "#{START} Select namespace:"

   return @prompt.select(question, namespaces, cycle: true, filter: true)
end

OptionParser.new do |parser|
   parser.banner = "Usage: example.rb [options]"

   parser.on("-c", "--context", "only set the namespace") do
      context = select_context()
      set_context(context)
      exit(true)
   end
   parser.on("-n", "--namespace", "only select the namespace for current context") do 
      context = get_current_context()
      namespace = select_namespace(context)
      set_namespace_for_context(namespace)
      exit(true)
   end
   parser.on("-h", "--help", "prints this help") do
      puts parser
      exit(true)
   end
   parser.on("-i", "--info", "prints context") do
      get_current_context()
      exit(true)
   end
end.parse!

context = select_context()
namespace = select_namespace(context)
set_context(context)
set_namespace_for_context(namespace, context=context)
exit(true)
