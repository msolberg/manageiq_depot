#
# Description: Retrieve a list of possible flavors for a virtual
# instance resize operation.
#
# This method checks populates a dynamic dropdown with the list of
# available flavors from the VMBD.
#


flavor_list = {}

vm = $evm.root['vm']
openstack = vm.ext_management_system

flavors = openstack.flavors

flavors.each do |flavor|
  flavor_list[flavor.name] = flavor.name
end

if flavor_list.length == 0
  flavor_list["none"] = "none"
end

dialog_field = $evm.object

# sort_by: value / description / none
dialog_field["sort_by"] = "none"

# required: true / false
# dialog_field["required"] = "true"

dialog_field["values"] = flavor_list
dialog_field["default_value"] = flavor_list.keys[0]

exit MIQ_OK
