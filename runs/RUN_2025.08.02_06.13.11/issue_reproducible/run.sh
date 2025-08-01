#!/bin/sh
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $dir;
export CLOCK_PORT='clk';
export CLOCK_WIRE_RC_LAYER='met5';
export CURRENT_DEF='0';
export CURRENT_NETLIST='./results/synthesis/CPU_core.v';
export CURRENT_ODB='0';
export CURRENT_POWERED_NETLIST='0';
export DATA_WIRE_RC_LAYER='met2';
export DESIGN_NAME='CPU_core';
export FP_PDN_ENABLE_GLOBAL_CONNECTIONS='1';
export FP_PDN_ENABLE_MACROS_GRID='1';
export LIB_FASTEST='pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib';
export LIB_SLOWEST='pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib';
export LIB_TYPICAL='pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib';
export MAX_FANOUT_CONSTRAINT='12';
export MAX_TRANSITION_CONSTRAINT='1.0';
export MERGED_LEF='./tmp/merged.nom.lef';
export OUTPUT_CAP_LOAD='17.65';
export PACKAGED_SCRIPT_0='openlane/scripts/openroad/sta/multi_corner.tcl';
export PACKAGED_SCRIPT_1='openlane/scripts/openroad/common/io.tcl';
export PACKAGED_SCRIPT_2='openlane/scripts/openroad/common/set_rc.tcl';
export PACKAGED_SCRIPT_3='openlane/designs/CPU_core/src/CPU_core.sdc';
export PACKAGED_SCRIPT_4='openlane/scripts/openroad/common/set_global_connections.tcl';
export PNR_SDC_FILE='openlane/designs/CPU_core/src/CPU_core.sdc';
export PROCESS_CORNER='nom';
export SAVE_LIB='./results/synthesis/CPU_core.lib';
export SAVE_NETLIST='./out.v';
export SAVE_SDF='./results/synthesis/CPU_core.sdf';
export SCRIPTS_DIR='openlane/scripts';
export SIGNOFF_SDC_FILE='openlane/designs/CPU_core/src/CPU_core.sdc';
export STA_MULTICORNER='0';
export STA_MULTICORNER_READ_LIBS='0';
export STA_PRE_CTS='1';
export STD_CELL_GROUND_PINS='VGND VNB';
export STD_CELL_POWER_PINS='VPWR VPB';
export _PROPAGATE_ALL_CLOCKS='0';
TOOL_BIN=${TOOL_BIN:-sta}
$TOOL_BIN -exit $PACKAGED_SCRIPT_0
