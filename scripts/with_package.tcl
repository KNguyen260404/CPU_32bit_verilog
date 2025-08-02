# Simple OpenLane Script with Package
# Run in OpenLane interactive mode

# Load OpenLane package
package require openlane

puts "OpenLane package loaded successfully!"
puts "Available commands:"
puts "  prep -design <design_name>"
puts "  run_synthesis"  
puts "  run_sta"
puts "  init_floorplan"
puts "  place_io"
puts "  tap_decap_or"
puts "  gen_pdn"
puts "  global_placement"
puts "  detailed_placement"
puts "  clock_tree_synthesis"
puts "  global_routing"
puts "  detailed_routing"
puts "  run_parasitics_sta"
puts "  run_magic"
puts "  run_lvs"
puts "  run_antenna_check"

# Example usage:
puts "\nExample flow:"
puts "1. prep -design CPU_core"
puts "2. run_synthesis"
puts "3. init_floorplan"
puts "4. place_io"
puts "5. global_placement"
puts "6. detailed_placement" 
puts "7. clock_tree_synthesis"
puts "8. global_routing"
puts "9. detailed_routing"
puts "10. run_parasitics_sta"
