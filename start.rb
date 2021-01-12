#!/usr/bin/env ruby

require_relative 'lib/mylog'
require_relative 'lib/client'
require_relative 'lib/testbox'
require_relative 'lib/templates'
require_relative 'lib/job'
require_relative 'lib/libvirt'
require_relative 'lib/upload'

def request_job(hostname, queues, logger)
	client = Client.new(hostname, queues)
	client.set_logger(logger)
	client.connect
	response = nil
	begin
		response = client.request_job
	rescue Exception => e
		logger.error(e.message)
	end
	return client, response
end

def save_job(client, response)
	job = Job.new(response)
	job.set_hostname(client.hostname)
	job.set_mac(client.mac)
	return job
end

def load_testbox(hostname, response, logger)
	testbox = Testbox.new(hostname, response)
	testbox.set_logger logger
	testbox.load
	return testbox
end

def generate_template(job, logger, upload)
	template = Templates.new(job)
	template.set_logger logger
	domain_path = nil
	begin
		template.get_final_template
		domain_path = template.save
	rescue Exception => e
		logger.error(e.backtrace)
	ensure
		upload.upload_file_curl logger.name
	end
	return domain_path
end

def start_vm(domain_path, logger, upload)
	libvirt = LibvirtConnect.new
	libvirt.set_logger logger
	begin
		libvirt.create(domain_path)
		upload.upload_qemu_log "/var/log/libvirt/qemu/#{upload.job.job_id}.log"
		libvirt.wait
	rescue Exception => e
		logger.error(e.message)
	ensure
		upload.upload_file_curl logger.name
		libvirt.close	
	end
end

def main(hostname, queues)
	logger = Mylog.new("#{hostname}.log")

	client, response = request_job(hostname, queues, logger)
	if response.nil? || response['job_id'].empty?
		puts '----------'
		puts 'no job now'
		puts'----------'
		logger.warn("no job now")
		return
	end

	job = save_job(client, response)

	# Testbox load kernel initrd
	testbox = load_testbox(hostname, response, logger)
	job.build(testbox)

	upload = Upload.new(job, logger)

	# TODO: combined template
	#domain_path = Templates.new(response, logger).transform(job)
	#puts "domain_path: #{domain_path}" 	
	domain_path = generate_template(job, logger, upload)

	return if domain_path.nil?
	upload.upload_file_curl 'domain.xml'	
	
	# debug 
	puts File.realpath(logger.name)
	puts "tail -f /srv/cci/serial/logs/#{hostname}"
	start_vm(domain_path, logger, upload)	
	
	client.close
	logger.close
end
