#!/usr/bin/env ruby

class Base
	attr_reader :logger, :upload
	# All instance variables are readable
	def method_missing(method, *args)
		field = "@#{method}".to_sym
		if instance_variables.include?(field)
			self.class.class_eval do
				attr_reader method
			end
			return instance_variable_get field
		end
		super
	end

	def set_logger(logger)
		@logger = logger
		self
	end

	def set_upload(upload)
		@upload = upload
		self
	end
end
