#
# Description: Refresh the Power States and Relationships for an instance.
#

require 'fog'

vm = $evm.root['vm']
vm.refresh()

$evm.log("info", "Refreshing Power States and Relationships for instance #{vm.name}")

exit MIQ_OK
