#
# Description: Converts Nova Metadata to ManageIQ tags.
#
# This method only assigns tags for categories which already
# exist in MiQ.  This keeps OpenStack users from arbitrarily
# creating new classifications.
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
  exit MIQ_ABORT
end

response = conn.get_server_details(vm.ems_ref)
response[:body]['server']['metadata'].each_pair{|k, v|
  tag_name = k.to_s.downcase.gsub(/\W/, '_')
  # Only assign the tag is the classification exists
  if $evm.execute('category_exists?', k)
    # Create this tag if it doesn't exist
    unless $evm.execute('tag_exists?', k, v)
      $evm.log("info", "Creating tag #{v}")
      $evm.execute('tag_create', k,
                   :name => tag_name,
                   :description => v)
    end
    
    # Apply the tag
    $evm.log("info", "Applying tag #{k}/#{v} to #{vm.name}")
    vm.tag_assign("#{k}/#{tag_name}")
  else
    $evm.log("info", "Not applying tag for classification #{k} for #{vm.name}.")
  end
}

exit MIQ_OK
