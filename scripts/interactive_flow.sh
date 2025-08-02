#!/bin/bash

# Interactive OpenLane Flow Controller
# CPU_core Design

DESIGN_NAME="CPU_core"
CURRENT_STEP=0

show_menu() {
    clear
    echo "============================================"
    echo "    OpenLane Interactive Flow Controller"
    echo "    Design: $DESIGN_NAME"
    echo "    Current Step: $CURRENT_STEP"
    echo "============================================"
    echo ""
    echo "Available Steps:"
    echo ""
    echo "  [0]  Design Preparation"
    echo "  [1]  Synthesis (Yosys)"
    echo "  [2]  Static Timing Analysis"
    echo "  [3]  Floorplan Initialization"
    echo "  [4]  IO Placement"
    echo "  [5]  Tap/Decap Insertion"
    echo "  [6]  PDN Generation"
    echo "  [7]  Global Placement"
    echo "  [8]  STA (Post-Placement)"
    echo "  [9]  Design Optimization"
    echo "  [10] Detailed Placement"
    echo "  [11] STA (Post-Detailed)"
    echo "  [12] Clock Tree Synthesis"
    echo "  [13] STA (Post-CTS)"
    echo "  [14] Timing Optimization"
    echo "  [15] Design Optimization"
    echo "  [16] STA (Pre-Route)"
    echo "  [17] Global Routing"
    echo "  [18] Detailed Routing"
    echo "  [19] Parasitic Extraction"
    echo "  [20] Final STA"
    echo "  [21] Sign-off Checks"
    echo ""
    echo "  [F]  Run Full Flow"
    echo "  [R]  Show Results"
    echo "  [C]  Clean Runs"
    echo "  [Q]  Quit"
    echo ""
    echo -n "Enter your choice: "
}

run_synthesis() {
    echo "Running Synthesis..."
    cd /home/nguyen2604/OpenLane/designs/CPU_core
    ./flow.tcl -design CPU_core -tag step1_synthesis -synth_only
    CURRENT_STEP=1
}

run_floorplan() {
    echo "Running Floorplan..."
    cd /home/nguyen2604/OpenLane/designs/CPU_core
    # Use OpenROAD commands
    echo "init_floorplan" | openroad
    CURRENT_STEP=3
}

run_placement() {
    echo "Running Placement..."
    cd /home/nguyen2604/OpenLane/designs/CPU_core
    echo "global_placement; detailed_placement" | openroad
    CURRENT_STEP=10
}

run_cts() {
    echo "Running Clock Tree Synthesis..."
    cd /home/nguyen2604/OpenLane/designs/CPU_core
    echo "clock_tree_synthesis" | openroad
    CURRENT_STEP=12
}

run_routing() {
    echo "Running Routing..."
    cd /home/nguyen2604/OpenLane/designs/CPU_core
    echo "global_routing; detailed_routing" | openroad
    CURRENT_STEP=18
}

show_results() {
    echo "========== Current Results =========="
    echo "Latest run directory:"
    ls -la runs/ | tail -1
    echo ""
    echo "Available reports:"
    find runs/RUN_* -name "*.rpt" 2>/dev/null | head -10
    echo ""
    read -p "Press Enter to continue..."
}

clean_runs() {
    echo "Cleaning all previous runs..."
    rm -rf runs/RUN_*
    echo "All runs cleaned."
    CURRENT_STEP=0
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        0)
            echo "Preparing design..."
            cd /home/nguyen2604/OpenLane/designs/CPU_core
            ./flow.tcl -design CPU_core -prep_only
            CURRENT_STEP=0
            ;;
        1)
            run_synthesis
            ;;
        2)
            echo "Running STA..."
            CURRENT_STEP=2
            ;;
        3)
            run_floorplan
            ;;
        7)
            run_placement
            ;;
        12)
            run_cts
            ;;
        18)
            run_routing
            ;;
        [Ff])
            echo "Running full flow..."
            cd /home/nguyen2604/OpenLane/designs/CPU_core
            ./flow.tcl -design CPU_core
            CURRENT_STEP=21
            ;;
        [Rr])
            show_results
            ;;
        [Cc])
            clean_runs
            ;;
        [Qq])
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Press Enter to continue..."
            read
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo "Step completed successfully!"
    else
        echo "Step failed with errors!"
    fi
    read -p "Press Enter to continue..."
done
