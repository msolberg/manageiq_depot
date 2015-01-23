#
# Description: Example method which verifies that a particular
# metadata tag exists.  In this example, we're checking for
# the tag "localization".  If the tag doesn't exist, we stop
# the instance.
#

require 'fog'

vm = $evm.root['vm']
openstack = vm.ext_management_system
auth_url = "http://#{openstack[:hostname]}:#{openstack[:port]}/v2.0/tokens"

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
  exit MIQ_ABORT
end

response = conn.get_server_details(vm.ems_ref)

localization = nil
response[:body]['server']['metadata'].each_pair{|k, v|
  if k == "localization"
    localization = v
  end
}

if localization.nil?
  vm.suspend()
  $evm.log("info", "Suspending instance #{vm.name} without localization set")
end

exit MIQ_OK
