#!/bin/bash

is_active()
{
	local name=$1
	local state=$(virsh dominfo $name | grep "State" | awk '{print $2}')
	[[ $state == "running" ]]
}
