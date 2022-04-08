#!/usr/bin/ruby

require "tty-command"
require "tty-prompt"
require "pastel"
require "optparse"

@prompt = TTY::Prompt.new(interrupt: :exit)
@cmd = TTY::Command.new(printer: TTY::Command::Printers::Null)
@pastel = Pastel.new

POD_ID_FILENAME = "pod_id.tmp"
CONTAINER_ID_FILENAME = "pod_id.tmp"

START = @pastel.green.bold("$")
WARN = @pastel.yellow.bold("!")
DONE =  "#{@pastel.blue.bold("!")} Done."

def write_id_to_file(id, filename)
   filename = "#{__dir__}/#{filename}"
   File.open(filename, 'w') { |file| file.write(id) }
end

def get_docker_containers(docker_output)
   containers = Hash.new
   container_strings = docker_output.split("\n")

   container_strings.each do |container_str|
      id, image, name = container_str.split(" ")
      containers["(#{id}) #{image} => #{name}"] = id
   end
   containers
end

def select_k8_pod()
   kube_output, err = @cmd.run("kubectl get pods -o name | cut -c 5-")
   if !kube_output || kube_output.strip.empty?
      puts "#{WARN} No running pods in namespace, exit"
      exit(1)
   end

   pods = kube_output.split("\n")
   @prompt.select("#{START} Select pod to exec into:", pods, cycle: true, filter: true)
end

def select_docker_container()
   docker_output, err = @cmd.run("docker ps | tail -n +2 | awk '{print $1, $2, $NF}'")

   if !docker_output || docker_output.strip.empty?
      puts "#{WARN} No running containers, exit"
      exit(1)
   end

   @prompt.select("#{START} Select a container to exec into:", get_docker_containers(docker_output), cycle: true, filter: true)
end

OptionParser.new do |parser|
   parser.banner = "Usage: exec.rb [options]"

   parser.on("-d", "--docker", "exec into a docker container") do
      container_id = select_docker_container()
      write_id_to_file(container_id, CONTAINER_ID_FILENAME)
      exit(true)
   end
   parser.on("-k", "--kube", "exec into a kubernetes pod") do
      pod_id = select_k8_pod()
      write_id_to_file(pod_id, CONTAINER_ID_FILENAME)
      exit(true)
   end
   parser.on("-h", "--help", "prints this help") do
      puts parser
      exit(true)
   end
end.parse!
