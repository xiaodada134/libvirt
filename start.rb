#!/usr/bin/env ruby

require_relative 'lib/mylog'
require_relative 'lib/client'
require_relative 'lib/testbox'
require_relative 'lib/templates'
require_relative 'lib/job'
require_relative 'lib/libvirt'
require_relative 'lib/upload'

def main(hostname, queues)
	logger = Mylog.new("#{hostname}.log")
	# logger.set_format
	client = Client.new(hostname, queues)
	client.set_logger(logger)
	client.connect
	
	# TODO
	# wait the boot.libvirt done
	response = client.request_job
	
	if response['job_id'].empty?
		puts '----------'
		puts 'no job now'
		puts'----------'
		logger.warn("no job now")
		return
	end

	job = Job.new(response)
	job.set_hostname(hostname)
	job.set_mac(client.mac)

	# Testbox load kernel initrd templates
	testbox = Testbox.new(hostname, response)
	testbox.set_logger logger
	testbox.load

	job.build(testbox)

	# TODO: combined template
	#domain_path = Templates.new(response, logger).transform(job)
	#puts "domain_path: #{domain_path}" 
	
	template = Templates.new(job)
	template.set_logger logger
	template.final_template
	domain_path = template.save

	upload = Upload.new(job, logger)
	upload.upload_file_curl "#{hostname}.log"
	upload.upload_file_curl 'domain.xml'	
	# log
	puts File.realpath("#{hostname}.log")
	puts "tail -f /srv/cci/serial/logs/#{hostname}"
	
	begin
		libvirt = LibvirtConnect.new
		libvirt.set_logger logger
		libvirt.create(domain_path)
		libvirt.wait
	rescue Exception => e
		logger.error(e.message)
	ensure
		upload.upload_file_curl "#{hostname}.log"
		# TODO
		# /var/log/libvirt/qemu/xxx.log
		upload.upload_rename_file "/var/log/libvirt/qemu/#{job.job_id}.log"
		libvirt.close
		client.close
		logger.close
	end
end
