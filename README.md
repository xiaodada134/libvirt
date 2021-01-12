yum install libvirt
systemctl start libvirtd
yum install -y  edk2-aarch64.noarch
gem install erb
yum install -y zlib-devel.aarch64
gem install nokogiri 

## kvm.sh
1. request scheudler
2. parse response
3. use domxml-from-cmd.rb transfer parameters to domain
generate domain.xml

## lib 
domxml-from-cmd
input: cmd
output: domain.xml
	accept parameter from cml save on config.rb
config.rb: 
input: cmd
output: config
	1. define the parameters that we may need
	2. bind(os.xml) use erb bind os template
	   bind(cpu.xml) user erb bind cpu template
generate-erb-template.rb
input: config
output: domain.xml
	1. ErbTemplate.new(config)
	2. save(output_path): save the result domain.xml at output_path
## templates
1. domain.xml
2. os.xml
3. interface.xml
4. devices.xml 
5. cpu.xml
...

## add new template
### not erb
add disk.xml
generate-erb-template.rb set_disk
### use erb
1. add disk.xml
2. Config add new attr : disk_file
3. generate-erb-template.rb : 
   @@disk_file = "disk.xml" 
   def set_disk 
4. get parameter from kvm.sh/pxe.sh
