#
# Description: Refresh the Power States and Relationships for a VM.
#

require 'fog'

vm = $evm.root['vm']
vm.refresh()

$evm.log("info", "Refreshing Power States and Relationships for VM #{vm.name}")

