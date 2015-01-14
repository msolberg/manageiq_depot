#
# Description: Backup an Instance by creating snapshots.
#

require 'fog'
require 'date'

vm = $evm.root['vm']
openstack = vm.ext_management_system
auth_url = "http://#{openstack[:hostname]}:#{openstack[:port]}/v2.0/tokens"

# TODO: This should be scoped to the tenant of the virtual machine
# instance and not "admin"
begin
  conn = Fog::Compute.new({
    :provider => 'OpenStack',
    :openstack_api_key  => openstack.authentication_password,
    :openstack_username => openstack.authentication_userid,
    :openstack_auth_url => auth_url,
    :openstack_tenant   => "admin"
  })
rescue => connerr
  $evm.log("error", "Couldn't connect to Openstack with provider credentials")
end

instance = conn.servers.get(vm.ems_ref)

$evm.log("info", "Starting Backup of #{vm.name}")

ts = DateTime.now().strftime(format="%Y%M%d%H%M%S")

begin
  instance.create_image("#{instance.name}-backup-#{ts}")
rescue => rebuilderr
  $evm.log("error", "Failed to backup VM #{rebuilderr}")
end

