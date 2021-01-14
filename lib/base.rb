#!/usr/bin/env ruby

class Base
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

	def hash_to_instance_var(hash)
		hash.each do |k,v|
			self.instance_variable_set("@#{k}", v)
			#if v.is_a?(String)
			#	eval "@#{k} = '#{v}'"
			#	next
			#end
			#eval "@#{k} = #{v}"
		end
	end

	def set_logger(logger)
		@logger = logger
		self
	end
end
