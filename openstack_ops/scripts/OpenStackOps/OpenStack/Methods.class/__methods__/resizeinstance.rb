#
# Description: Resize an instance to the flavor specified in
# dialog_Flavor
#

require 'fog'

vm = $evm.root['vm']
target_flavor = $evm.root['dialog_Flavor']

$evm.log("info", "Got request to resize #{vm.name} to #{target_flavor}")

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

instance   = conn.servers.get(vm.ems_ref)

flavor_ref = nil
conn.flavors.each do |flavor|
  if flavor.name == target_flavor
    flavor_ref = flavor.id
  end
end

if flavor_ref != nil
  begin
    instance.resize(flavor_ref)
  rescue => resizeeerr
    $evm.log("error", "Failed to reize VM #{resizeeerr}")
  end
else
  $evm.log("error", "Could not find flavor #{target_flavor} in region.  Resize failed.")
end
