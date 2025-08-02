#!/bin/bash

# OpenLane Step-by-step Execution Script for CPU_core
# Usage: ./run_individual_steps.sh [step_number]
# Example: ./run_individual_steps.sh 1  (runs only synthesis)

DESIGN_NAME="CPU_core"
OPENLANE_ROOT="/openlane"

# Function to run specific step
run_step() {
    step=$1
    case $step in
        0)
            echo "========== STEP 0: Design Preparation =========="
            ./flow.tcl -design $DESIGN_NAME -tag prep_only -prep_only
            ;;
        1)
            echo "========== STEP 1: Synthesis =========="
            ./flow.tcl -design $DESIGN_NAME -tag synth_only -synth_only
            ;;
        2)
            echo "========== STEP 2: Floorplan =========="
            ./flow.tcl -design $DESIGN_NAME -tag floorplan_only -from init_floorplan -to place_io
            ;;
        3)
            echo "========== STEP 3: Placement =========="
            ./flow.tcl -design $DESIGN_NAME -tag placement_only -from global_placement -to detailed_placement
            ;;
        4)
            echo "========== STEP 4: CTS (Clock Tree Synthesis) =========="
            ./flow.tcl -design $DESIGN_NAME -tag cts_only -from clock_tree_synthesis -to resizer_timing
            ;;
        5)
            echo "========== STEP 5: Routing =========="
            ./flow.tcl -design $DESIGN_NAME -tag routing_only -from global_routing -to detailed_routing
            ;;
        6)
            echo "========== STEP 6: Sign-off =========="
            ./flow.tcl -design $DESIGN_NAME -tag signoff_only -from run_parasitics_sta -to run_antenna_check
            ;;
        full)
            echo "========== RUNNING FULL FLOW =========="
            ./flow.tcl -design $DESIGN_NAME
            ;;
        *)
            echo "Usage: $0 [0|1|2|3|4|5|6|full]"
            echo "  0: Design Preparation"
            echo "  1: Synthesis"
            echo "  2: Floorplan"
            echo "  3: Placement"
            echo "  4: Clock Tree Synthesis"
            echo "  5: Routing"
            echo "  6: Sign-off"
            echo "  full: Complete flow"
            exit 1
            ;;
    esac
}

# Function to show current results
show_results() {
    echo "========== CURRENT RESULTS =========="
    find runs/RUN_* -name "*.rpt" -o -name "*.log" | head -10
    echo "Latest run directory:"
    ls -la runs/ | tail -1
}

# Function to view specific reports
view_report() {
    report_type=$1
    case $report_type in
        synthesis)
            find runs/RUN_* -name "*synthesis*" -type f | head -5
            ;;
        timing)
            find runs/RUN_* -name "*sta*" -o -name "*timing*" | head -5
            ;;
        power)
            find runs/RUN_* -name "*power*" | head -5
            ;;
        area)
            find runs/RUN_* -name "*area*" | head -5
            ;;
        *)
            echo "Available reports: synthesis, timing, power, area"
            ;;
    esac
}

# Function to clean previous runs
clean_runs() {
    echo "Cleaning previous runs..."
    rm -rf runs/RUN_*
    echo "All previous runs cleared."
}

# Main execution
case $1 in
    clean)
        clean_runs
        ;;
    results)
        show_results
        ;;
    report)
        view_report $2
        ;;
    *)
        run_step $1
        ;;
esac
