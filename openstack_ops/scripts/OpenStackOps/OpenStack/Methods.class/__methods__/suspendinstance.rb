#
# Description: Suspend an Instance.
#

require 'fog'

vm = $evm.root['vm']

begin
  vm.suspend()
  $evm.log("info", "Suspending instance #{vm.name}")
rescue => suspenderr
  $evm.log("error", "Failed to suspend instance #{vm.name}: #{suspenderr}")
  exit MIQ_ABORT
end

exit MIQ_OK
