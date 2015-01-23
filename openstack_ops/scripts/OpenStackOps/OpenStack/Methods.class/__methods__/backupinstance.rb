#
# Description: Backup an Instance by creating snapshots.
#

require 'fog'
require 'date'

vm = $evm.root['vm']
openstack = vm.ext_management_system

tenant_name = nil
openstack.cloud_tenants.each do |tenant|
  if tenant.id == vm.cloud_tenant_id
    tenant_name = tenant.name
  end
end

if tenant_name == nil
  $evm.log("error", "Couldn't find tenant #{vm.cloud_tenant_id} associated with vm #{vm.name}")
  exit MIQ_ABORT
end

auth_url = "http://#{openstack[:hostname]}:#{openstack[:port]}/v2.0/tokens"

begin
  conn = Fog::Compute.new({
    :provider => 'OpenStack',
    :openstack_api_key  => openstack.authentication_password,
    :openstack_username => openstack.authentication_userid,
    :openstack_auth_url => auth_url,
    :openstack_tenant   => tenant_name
  })
rescue => connerr
  $evm.log("error", "Couldn't connect to Openstack with provider credentials")
  exit MIQ_ABORT
end

instance = conn.servers.get(vm.ems_ref)
ts = DateTime.now().strftime(format="%Y%M%d%H%M%S")
snapname = "#{instance.name}-backup-#{ts}"

begin
  instance.create_image(snapname)
  $evm.log("info", "Created snapshot #{snapname} for instance #{vm.name}") 
rescue => rebuilderr
  $evm.log("error", "Failed to snapshot instance #{vm.name}: #{rebuilderr}")
  exit MIQ_ABORT
end

exit MIQ_OK
