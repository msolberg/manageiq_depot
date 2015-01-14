#
# Description: This method checks to see if the VM has been powered off or suspended
#

# Get vm from root object
vm = $evm.root['vm']

unless vm.nil?
  power_state = vm.attributes['power_state']
  $evm.log('info', "VM:<#{vm.name}> has Power State:<#{power_state}>")

  if power_state == "off" || power_state == "suspended"
    # Bump State
    $evm.root['ae_result'] = 'ok'
  elsif power_state == "never" || power_state == "unknown"
    $evm.root['ae_result'] = 'error'
    exit MIQ_ABORT
  else
    $evm.root['ae_result']         = 'retry'
    $evm.root['ae_retry_interval'] = '1.minute'
  end
end
