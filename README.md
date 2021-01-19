# tool
```shell
yum install -y libvirt
systemctl start libvirtd
yum install -y  edk2-aarch64.noarch
gem install erb
yum install -y zlib-devel.aarch64
gem install nokogiri 
yum install -y libvirt-devel.aarch64
gem install ruby-libvirt
```

# how to use
## use owns template
1. define templates on your yaml
job.yaml
```yaml
vt:
	domain: xsw0112.xml
```

2. save xsw0112.xml file to $LKP_SRC/hosts

## use default template
no need define templates on job.yaml


# libvirt
---

## client.rb
logger: define a log
Consumer: request job
Context: save configuration
Executor: load file
Domain: generate domain.xml
Upload: upload log file
Libvirt: create VM

## lib
---

### base.rb
set_logger: link a logger
set_upload: link a upload

### consumer.rb
request_job: request job based on mac

### executor.rb
load: load kernel initrd file, parse $LKP_SRC/hosts/libvirt-2p16g

### domain.rb
create_domain: base response generate domain.xml
save: save to a file

### context.rb
this class will save some vars
	like: kernel initrd cmdline nr_cpu memory ...
expand_erb: translation a erb template file

### upload.rb
upload_vm_log: upload vm boot log
upload_qemu_log: upload /var/log/libvirt/qemu/xxx.log
upload_client_log: upload program run log

### libvirt.rb
create: based a xml file create a VM
wait: wait the VM shutdown

## templates

option.yaml: define every template role

