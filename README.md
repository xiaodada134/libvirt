# tool
```shell
yum install libvirt
systemctl start libvirtd
yum install -y  edk2-aarch64.noarch
gem install erb
yum install -y zlib-devel.aarch64
gem install nokogiri 
```

# how to use
## use owns template
1. define templates on your yaml
job.yaml
```yaml
templates:
	domain: xsw0112.xml
```

2. save xsw0112.xml file to $LKP_SRC/hosts

## use default template
no need define templates on job.yaml


# libvirt
---

## start.rb
logger: define a log
client: request job
job: save configuration
testbox: load file
template: generate domain.xml
upload: upload log file
libvirt: create VM

## lib
---

### base.rb
method_missing: set All instance variables are readable
hash_to_instance_var: translate hash to obj
set_logger: link a logger

### client.rb
connect: config scheduler and register mac hostname and queues
request_job: request job based on mac

### testbox.rb
load: load kernel initrd file, parse $LKP_SRC/hosts/libvirt-2p16g

### templates.rb
final_template: base response generate domain.xml
save: save to a file

### job.rb
this class will save some vars
	like: kernel initrd cmdline nr_cpu memory ...
bind: translation a erb template file

### upload.rb
upload_file_curl: upload a file to result_root use curl command
upload_rename_file: upload /var/log/libvirt/qemu/xxx.log

### libvirt.rb
create: based a xml file create a VM
wait: wait the VM shutdown
