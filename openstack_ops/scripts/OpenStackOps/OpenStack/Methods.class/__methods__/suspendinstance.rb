#
# Description: Suspend an Instance.
#

require 'fog'

vm = $evm.root['vm']

$evm.log("info", "Suspending instance #{vm.name}")

begin
  vm.suspend()
rescue => suspenderr
  $evm.log("error", "Failed to suspend VM #{suspenderr}")
end

