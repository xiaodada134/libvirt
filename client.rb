#!/usr/bin/env ruby

require_relative 'lib/mylog'
require_relative 'lib/consumer'
require_relative 'lib/executor'
require_relative 'lib/domain'
require_relative 'lib/context'
require_relative 'lib/libvirt'
require_relative 'lib/upload'

def start_vm(domain_file, libvirt)
	begin
		libvirt.create(domain_file)
		libvirt.wait
	rescue Exception => e
		libvirt.logger.error(e.message)
	ensure
		# upload
		libvirt.upload.upload_client_log
	end
end

def generate_domain(domain)
	domain_path = nil
	begin
		domain.create_domain
		domain_path = domain.save('domain.xml') 
	rescue Exception => e
		domain.logger.error(e.message)
	ensure
		domain.upload.upload_client_log	
	end
	return domain_path
end

def main(hostname, queues)
	puts "cat #{hostname}.log"
	logger = Mylog.new("#{hostname}.log")
	consumer = Consumer.new(hostname, queues).set_logger logger
	# ensure if libvirt error not consume job
	libvirt = LibvirtConnect.new().set_logger logger

	response = consumer.request_job
	if response.nil? || response['job_id'].empty?
		logger.warn('no job now')
		puts '----------'
		puts 'no job now'
		puts '----------'
		return
	end
	context = Context.new(response).set_logger logger
	context.merge!(consumer.info)


	executor = Executor.new(hostname, response).set_logger logger
	executor.load
	context.merge!(executor.config)

	upload = Upload.new(context, logger)
	libvirt.set_upload(upload)
	
	domain = Domain.new(context).set_logger(logger).set_upload(upload)
	domain_file = generate_domain(domain)

	puts "tail -f #{context.config.log_file}"	
	start_vm(domain_file, libvirt)

	## clean env
	consumer.close
	libvirt.close
	logger.close
end
