# OpenLane Step-by-step Execution Script
# CPU_core Design Flow

# Initialize OpenLane package
package require openlane

# Set design name
set design_name "CPU_core"

# Step 0: Design Preparation
puts "========== STEP 0: Design Preparation =========="
prep -design $design_name

# Step 1: Synthesis
puts "========== STEP 1: Synthesis =========="
run_synthesis

# Step 2: STA after Synthesis
puts "========== STEP 2: Static Timing Analysis (Post-Synthesis) =========="
run_sta

# Step 3: Floorplanning
puts "========== STEP 3: Floorplan Initialization =========="
init_floorplan

# Step 4: IO Placement
puts "========== STEP 4: IO Placement =========="
place_io

# Step 5: Tap/Decap Insertion
puts "========== STEP 5: Tap/Decap Insertion =========="
tap_decap_or

# Step 6: PDN Generation
puts "========== STEP 6: Power Distribution Network =========="
gen_pdn

# Step 7: Global Placement
puts "========== STEP 7: Global Placement =========="
global_placement

# Step 8: STA after Global Placement
puts "========== STEP 8: Static Timing Analysis (Post-Global Placement) =========="
run_sta

# Step 9: Design Optimization (Resizer)
puts "========== STEP 9: Design Optimization =========="
resizer_design

# Step 10: Detailed Placement
puts "========== STEP 10: Detailed Placement =========="
detailed_placement

# Step 11: STA after Detailed Placement
puts "========== STEP 11: Static Timing Analysis (Post-Detailed Placement) =========="
run_sta

# Step 12: Clock Tree Synthesis
puts "========== STEP 12: Clock Tree Synthesis =========="
clock_tree_synthesis

# Step 13: STA after CTS
puts "========== STEP 13: Static Timing Analysis (Post-CTS) =========="
run_sta

# Step 14: Timing Optimization
puts "========== STEP 14: Timing Optimization =========="
resizer_timing

# Step 15: Design Optimization (Post-CTS)
puts "========== STEP 15: Design Optimization (Post-CTS) =========="
resizer_design

# Step 16: STA after Optimization
puts "========== STEP 16: Static Timing Analysis (Post-Optimization) =========="
run_sta

# Step 17: Final Timing Optimization
puts "========== STEP 17: Final Timing Optimization =========="
resizer_timing

# Step 18: Final STA before Routing
puts "========== STEP 18: Final STA before Routing =========="
run_sta

# Step 19: Write Verilog (Post-CTS)
puts "========== STEP 19: Write Verilog =========="
write_verilog $::env(synthesis_results)/$::env(DESIGN_NAME).v

# Step 20: Global Routing
puts "========== STEP 20: Global Routing =========="
global_routing

# Step 21: Fill Insertion
puts "========== STEP 21: Fill Insertion =========="
run_fill_insertion

# Step 22: Detailed Routing
puts "========== STEP 22: Detailed Routing =========="
detailed_routing

# Step 23: Wire Length Calculation
puts "========== STEP 23: Wire Length Calculation =========="
run_magic_spice_export

# Step 24: Parasitic Extraction
puts "========== STEP 24: Parasitic Extraction =========="
run_parasitics_sta

# Step 25: Final STA with Parasitics
puts "========== STEP 25: Final STA with Parasitics =========="
run_sta

# Step 26: IR Drop Analysis
puts "========== STEP 26: IR Drop Analysis =========="
run_irdrop_report

# Step 27: GDSII Generation
puts "========== STEP 27: GDSII Generation =========="
run_magic

# Step 28: LEF Generation
puts "========== STEP 28: LEF Generation =========="
run_magic_lef_export

# Step 29: GDS Streaming
puts "========== STEP 29: GDS Streaming (KLayout) =========="
run_klayout_gds

# Step 30: SPICE Extraction
puts "========== STEP 30: SPICE Extraction =========="
run_magic_spice_export

# Step 31: Write Final Verilog
puts "========== STEP 31: Write Final Verilog =========="
write_verilog $::env(finishing_results)/$::env(DESIGN_NAME).v
write_powered_verilog

# Step 32: LVS (Layout vs Schematic)
puts "========== STEP 32: Layout vs Schematic (LVS) =========="
run_lvs

# Step 33: Antenna Check
puts "========== STEP 33: Antenna Check =========="
run_antenna_check

# Final Reports
puts "========== FINAL: Generate Reports =========="
run_magic_drc
generate_final_summary_report

puts "========== FLOW COMPLETED SUCCESSFULLY =========="
