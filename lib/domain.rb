#!/usr/bin/env ruby

require 'json'
require 'set'
require 'nokogiri'
require 'yaml'
require_relative 'hashugar'
require_relative 'base'
require_relative 'active'

# get templates from local or default
# support 
# case 1:
# 	user define a domain.xml on job
# case 2:
# 	user default templates
# case 3:
# 	TODO:user define cpu disk ...
class Domain < Base
	include Active

	@doc = nil

	def initialize(context)
		@context = context
		@option = Hashugar.new(YAML.load(File.read(@@OPTION_FILE)))
	end

	def create_domain
		domain_option
		domain
		if user_domain?
			common_option
			return
		end
		
		replaceable_option
		common_option
	end

	def save(filename)
		File.open(filename, 'w') do |f|
			f.puts @doc.to_xml
		end
		@upload.upload_file filename
		File.realpath(filename)
	end

	private

	def common_option
		@option.common.each do |one|
			self.instance_eval one		
		end
		@logger.info("Common option: #{@option.common.to_s}")
	end

	# TODO
	def merge_replaceable_option
	end

	def replaceable_option
		@option.replaceable.each do |one|
			self.instance_eval one
		end
		@logger.info("Replaceable option :#{@option.replaceable.to_s}")
	end

	def domain_option
		@domain_option = "#{@@TEMPLATE_DIR}/#{@option.domain}.xml"
		if user_domain?
			@domain_option = "#{@@USER_DIR}/#{@context.info['templates']['domain']}"
		end
		@logger.debug("Domain: #{@domain_option}")
	end

	def user_domain?
		if @context.info['templates'].nil?
			return false
		end
		if @context.info['templates'].key?('domain')
			return true
		else
			return false
		end
	end
end
