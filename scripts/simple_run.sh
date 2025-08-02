#!/bin/bash

# Simple OpenLane Step Runner
# Usage: ./simple_run.sh [step]

DESIGN="CPU_core"

case $1 in
    "prep"|"0")
        echo "Running Design Preparation..."
        ./flow.tcl -design $DESIGN -tag prep_$(date +%H%M) -init_design_config -prep_only
        ;;
    "synth"|"1") 
        echo "Running Synthesis..."
        ./flow.tcl -design $DESIGN -tag synth_$(date +%H%M) -from run_synthesis -to run_synthesis
        ;;
    "floorplan"|"2")
        echo "Running Floorplan..."
        ./flow.tcl -design $DESIGN -tag floor_$(date +%H%M) -from init_floorplan -to gen_pdn
        ;;
    "place"|"3")
        echo "Running Placement..."
        ./flow.tcl -design $DESIGN -tag place_$(date +%H%M) -from global_placement -to detailed_placement
        ;;
    "cts"|"4")
        echo "Running CTS..."
        ./flow.tcl -design $DESIGN -tag cts_$(date +%H%M) -from clock_tree_synthesis -to clock_tree_synthesis
        ;;
    "route"|"5")
        echo "Running Routing..."
        ./flow.tcl -design $DESIGN -tag route_$(date +%H%M) -from global_routing -to detailed_routing
        ;;
    "signoff"|"6")
        echo "Running Sign-off..."
        ./flow.tcl -design $DESIGN -tag signoff_$(date +%H%M) -from run_parasitics_sta
        ;;
    "full"|"all")
        echo "Running Full Flow..."
        ./flow.tcl -design $DESIGN
        ;;
    "interactive"|"i")
        echo "Starting Interactive Mode..."
        ./flow.tcl -design $DESIGN -interactive
        ;;
    *)
        echo "Usage: $0 [step]"
        echo ""
        echo "Available steps:"
        echo "  prep, 0     - Design Preparation"
        echo "  synth, 1    - Synthesis" 
        echo "  floorplan, 2 - Floorplan"
        echo "  place, 3    - Placement"
        echo "  cts, 4      - Clock Tree Synthesis"
        echo "  route, 5    - Routing"
        echo "  signoff, 6  - Sign-off"
        echo "  full, all   - Complete Flow"
        echo "  interactive, i - Interactive Mode"
        echo ""
        echo "Example: $0 synth"
        ;;
esac
