#!/usr/bin/env ruby

require 'yaml'

LKP_SRC = "#{ENV['LKP_SRC']}"

def dict_to_obj(dict, obj)
	dict.each do |k,v|
		eval "obj.#{k} = '#{v}'"
	end
end

def get_mac_from_hostname(hostname)
	cmd = %Q(echo #{hostname} | md5sum | sed "s/^\\(..\\)\\(..\\)\\(..\\)\\(..\\)\\(..\\).*$/0a-\\1-\\2-\\3-\\4-\\5/")
	%x(#{cmd}).chomp
end

def set_host_info(mac, hostname, queues)
	system "curl -X PUT 'http://#{SCHED_HOST}:#{SCHED_PORT}/set_host_mac?hostname=#{hostname}&mac=#{mac}'"
	system "curl -X PUT 'http://#{SCHED_HOST}:#{SCHED_PORT}/set_host2queues?host=#{hostname}&queues=#{queues}'"
end

def del_host_info(mac, hostname)
	system "curl -X PUT 'http://#{SCHED_HOST}:#{SCHED_PORT}/del_host_mac?mac=#{mac}'"
	system "curl -X PUT 'http://#{SCHED_HOST}:#{SCHED_PORT}/del_host2queues?host=#{hostname}'"
end

def parse_host_from_hostname(hostname)
	hostname.split('.')[0]
end

def create_yaml_variables(host)
	host_file = "#{LKP_SRC}/hosts/#{host}"
	YAML.load(File.read(host_file))
end


