#!/usr/bin/env tclsh

# OpenLane Complete Flow Script with all required packages
# Usage: Run this script in OpenLane environment

# Load required packages
package require openlane 2.0

# Initialize OpenLane environment
set script_dir [file dirname [file normalize [info script]]]

# Set design configuration
set design_name "CPU_core"
set design_dir "designs/CPU_core"

# Source OpenLane configuration
if {[file exists "$design_dir/config.json"]} {
    puts "Loading design configuration..."
} else {
    puts "ERROR: Configuration file not found!"
    exit 1
}

# Main flow execution
proc run_complete_flow {design} {
    puts "Starting complete OpenLane flow for $design"
    
    # Step 0: Design Preparation
    puts "\n========== STEP 0: Design Preparation =========="
    if {[catch {prep -design $design} error]} {
        puts "ERROR in prep: $error"
        return -1
    }
    
    # Step 1: Synthesis
    puts "\n========== STEP 1: Synthesis =========="
    if {[catch {run_synthesis} error]} {
        puts "ERROR in synthesis: $error"
        return -1
    }
    
    # Step 2: Static Timing Analysis
    puts "\n========== STEP 2: Static Timing Analysis =========="
    if {[catch {run_sta} error]} {
        puts "ERROR in STA: $error"
        return -1
    }
    
    # Step 3: Floorplan
    puts "\n========== STEP 3: Floorplan Initialization =========="
    if {[catch {init_floorplan} error]} {
        puts "ERROR in floorplan: $error"
        return -1
    }
    
    # Step 4: IO Placement
    puts "\n========== STEP 4: IO Placement =========="
    if {[catch {place_io} error]} {
        puts "ERROR in IO placement: $error"
        return -1
    }
    
    # Step 5: Tap/Decap Insertion
    puts "\n========== STEP 5: Tap/Decap Insertion =========="
    if {[catch {tap_decap_or} error]} {
        puts "ERROR in tap/decap: $error"
        return -1
    }
    
    # Step 6: PDN Generation
    puts "\n========== STEP 6: Power Distribution Network =========="
    if {[catch {gen_pdn} error]} {
        puts "ERROR in PDN: $error"
        return -1
    }
    
    # Step 7: Global Placement
    puts "\n========== STEP 7: Global Placement =========="
    if {[catch {global_placement} error]} {
        puts "ERROR in global placement: $error"
        return -1
    }
    
    # Step 8: STA after Placement
    puts "\n========== STEP 8: STA after Placement =========="
    if {[catch {run_sta} error]} {
        puts "WARNING in post-placement STA: $error"
    }
    
    # Step 9: Detailed Placement
    puts "\n========== STEP 9: Detailed Placement =========="
    if {[catch {detailed_placement} error]} {
        puts "ERROR in detailed placement: $error"
        return -1
    }
    
    # Step 10: Clock Tree Synthesis
    puts "\n========== STEP 10: Clock Tree Synthesis =========="
    if {[catch {clock_tree_synthesis} error]} {
        puts "ERROR in CTS: $error"
        return -1
    }
    
    # Step 11: STA after CTS
    puts "\n========== STEP 11: STA after CTS =========="
    if {[catch {run_sta} error]} {
        puts "WARNING in post-CTS STA: $error"
    }
    
    # Step 12: Global Routing
    puts "\n========== STEP 12: Global Routing =========="
    if {[catch {global_routing} error]} {
        puts "ERROR in global routing: $error"
        return -1
    }
    
    # Step 13: Detailed Routing
    puts "\n========== STEP 13: Detailed Routing =========="
    if {[catch {detailed_routing} error]} {
        puts "ERROR in detailed routing: $error"
        return -1
    }
    
    # Step 14: Parasitic Extraction and Final STA
    puts "\n========== STEP 14: Final STA with Parasitics =========="
    if {[catch {run_parasitics_sta} error]} {
        puts "WARNING in final STA: $error"
    }
    
    # Step 15: Generate Final Files
    puts "\n========== STEP 15: Generate Final Files =========="
    if {[catch {run_magic} error]} {
        puts "WARNING in GDSII generation: $error"
    }
    
    if {[catch {run_magic_spice_export} error]} {
        puts "WARNING in SPICE export: $error"
    }
    
    # Step 16: Verification
    puts "\n========== STEP 16: Verification =========="
    if {[catch {run_lvs} error]} {
        puts "WARNING in LVS: $error"
    }
    
    if {[catch {run_antenna_check} error]} {
        puts "WARNING in antenna check: $error"
    }
    
    puts "\n=========================================="
    puts "OpenLane Flow Completed!"
    puts "Check results in runs/ directory"
    puts "=========================================="
    
    return 0
}

# Execute the flow
if {[run_complete_flow $design_name] == 0} {
    puts "SUCCESS: Flow completed successfully"
    exit 0
} else {
    puts "FAILED: Flow failed with errors"
    exit 1
}
