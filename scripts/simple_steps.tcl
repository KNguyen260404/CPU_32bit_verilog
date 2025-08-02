# Simple OpenLane Commands Script
# Run this in OpenLane interactive mode
# Usage: source designs/CPU_core/scripts/simple_steps.tcl

puts "Starting OpenLane Step-by-Step Flow for CPU_core"
puts "================================================"

# Function to wait for user input
proc wait_for_user {step_name} {
    puts "\n>>> Completed: $step_name"
    puts ">>> Press Enter to continue to next step..."
    gets stdin
}

# Step 1: Prepare Design
puts "\n========== STEP 1: Design Preparation =========="
prep -design CPU_core
wait_for_user "Design Preparation"

# Step 2: Synthesis
puts "\n========== STEP 2: Synthesis =========="
run_synthesis
wait_for_user "Synthesis"

# Step 3: Static Timing Analysis
puts "\n========== STEP 3: Static Timing Analysis =========="
run_sta
wait_for_user "Post-Synthesis STA"

# Step 4: Floorplan
puts "\n========== STEP 4: Floorplan =========="
init_floorplan
wait_for_user "Floorplan Initialization"

# Step 5: IO Placement
puts "\n========== STEP 5: IO Placement =========="
place_io
wait_for_user "IO Placement"

# Step 6: Tap/Decap Insertion
puts "\n========== STEP 6: Tap/Decap Insertion =========="
tap_decap_or
wait_for_user "Tap/Decap Insertion"

# Step 7: PDN Generation
puts "\n========== STEP 7: Power Distribution Network =========="
gen_pdn
wait_for_user "PDN Generation"

# Step 8: Global Placement
puts "\n========== STEP 8: Global Placement =========="
global_placement
wait_for_user "Global Placement"

# Step 9: STA after Placement
puts "\n========== STEP 9: STA after Placement =========="
run_sta
wait_for_user "Post-Placement STA"

# Step 10: Detailed Placement
puts "\n========== STEP 10: Detailed Placement =========="
detailed_placement
wait_for_user "Detailed Placement"

# Step 11: Clock Tree Synthesis
puts "\n========== STEP 11: Clock Tree Synthesis =========="
clock_tree_synthesis
wait_for_user "Clock Tree Synthesis"

# Step 12: STA after CTS
puts "\n========== STEP 12: STA after CTS =========="
run_sta
wait_for_user "Post-CTS STA"

# Step 13: Global Routing
puts "\n========== STEP 13: Global Routing =========="
global_routing
wait_for_user "Global Routing"

# Step 14: Detailed Routing
puts "\n========== STEP 14: Detailed Routing =========="
detailed_routing
wait_for_user "Detailed Routing"

# Step 15: Parasitic Extraction & Final STA
puts "\n========== STEP 15: Final Timing Analysis =========="
run_parasitics_sta
wait_for_user "Final STA with Parasitics"

# Step 16: Generate Final Files
puts "\n========== STEP 16: Generate Final Files =========="
run_magic
run_magic_spice_export
wait_for_user "File Generation"

# Step 17: Verification
puts "\n========== STEP 17: Verification =========="
run_lvs
run_antenna_check
wait_for_user "Verification"

puts "\n=========================================="
puts "OpenLane Flow Completed Successfully!"
puts "Check the results in runs/ directory"
puts "=========================================="
