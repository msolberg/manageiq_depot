#
# Description: Start an Instance.
#

require 'fog'
require 'restclient'

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
token = conn.auth_token
url = "#{instance.links[0]['href']}/action"
timeout = 60


payload = JSON.dump(
  {
    "os-start" => nil
  }
)

begin
  result = RestClient::Request.execute({
                                        :method  => :post,
                                        :url     => url,
                                        :payload => payload,
                                        :timeout => timeout,
                                        :headers => { :accept => 'version=2', :content_type => 'application/json', 'X-Auth-Token' => token }
                                           })
  $evm.log("info", "Starting instance #{vm.name}")

rescue => starterr
  if #{starterr} == "409 Conflict"
    $evm.root['ae_result'] = "retry"
    $evm.root['ae_retry_interval'] = "1.minute"
    $evm.log("info", "Couldn't start instance #{vm.name}: retrying.")
  else
    $evm.root['ae_result'] = "error"
    $evm.log("error", "Couldn't start instance #{vm.name}: #{starterr}")
    exit MIQ_ABORT
  end
end

exit MIQ_OK
