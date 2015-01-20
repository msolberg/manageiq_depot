#
# Description: Rebuild an Instance from its original image.
#

require 'fog'

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
end

instance = conn.servers.get(vm.ems_ref)
image_ref = instance.image['id']

$evm.log("info", "Rebuilding #{vm.name} with image #{image_ref}")

begin
  instance.rebuild(image_ref, instance.name)
rescue => rebuilderr
  $evm.log("error", "Failed to rebuild VM #{rebuilderr}")
end

