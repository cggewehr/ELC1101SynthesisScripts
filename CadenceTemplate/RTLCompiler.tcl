
# Last update: 15 Dec 2020, Carlos Gewehr

#-----------------------------------------------------------------------------
# General Comments
#-----------------------------------------------------------------------------
puts "  "
puts "  "
puts "  "
puts "  "

#-----------------------------------------------------------------------------
# Main Custom Variables Design Dependent (exported by run_synthesis.sh)
#-----------------------------------------------------------------------------
set PROJECT_DIR $env(PROJECT_DIR)
#set TECH_DIR $env(TECH_DIR)
#set DESIGNS $env(DESIGNS)
set TOP_LVL_ENTITY $env(TOP_LVL_ENTITY)
set CLOCK_PERIOD $env(CLOCK_PERIOD)
#puts $RUN_CORNER
set RUN_CORNER $env(CORNER)
set VCD_SIM_FLAG $env(VCD_SIM_FLAG)
set OPTIMIZE_FLAG $env(OPTIMIZE_FLAG)

#-----------------------------------------------------------------------------
# MAIN Custom Variables to be used in SDC (constraints file)
#-----------------------------------------------------------------------------
set INTERCONNECT_MODE ple

# These must match the net names in top level RTL
set MAIN_CLOCK_NAME clk
set MAIN_RST_NAME rst

#set OPERATING_CONDITIONS PwcV162T125_STD_CELL_7RF
set period_clk $env(CLOCK_PERIOD)  ;#clk = 10.00MHz = 100ns (period)
set clk_uncertainty 0.25 ;# ns (“a guess”)
set clk_latency 0.35 ;# ns (“a guess”)
set in_delay 1 ;# ns
set out_delay 2.958 ;#ns BC1820PU_PM_A (1.518 + 0.032xCL) = (1.518 + 0.032x45 fF)
set out_load 0.045 ;#pF (15 fF + 30 fF) = pin A of IO Cell BC1820PU_PM_A (15 fF) + “a guess”
set slew "146 164 264 252" ;#minimum rise, minimum fall, maximum rise and maximum fall - pin Z of IO Cell BC1820PU_PM_A
set slew_min_rise 0.146 ;# ns
set slew_min_fall 0.164 ;# ns
set slew_max_rise 0.264 ;# ns
set slew_max_fall 0.252 ;# ns

#set WORST_LIST {PwcV162T125_STD_CELL_7RF.lib} 
set LEF_LIST {cmos7rf_6ML_tech.lef ibm_cmos7rf_sc_12Track.lef}

if {${RUN_CORNER} == "wc"} {  ;# Set vars for worst case (1.62V @ 125C)
    set OPERATING_CONDITIONS PwcV162T125_STD_CELL_7RF
    set CELL_LIB_LIST {PwcV162T125_STD_CELL_7RF.lib}
} elseif {${RUN_CORNER} == "nc"} {  ;# Set vars for nominal case (1.8V @ 25C)
    set OPERATING_CONDITIONS PnomV180T025_STD_CELL_7RF
    set CELL_LIB_LIST {PnomV180T025_STD_CELL_7RF.lib}
} elseif {${RUN_CORNER} == "bc"} {  ;# Set vars for best case (1.98V @ -40C)
    set OPERATING_CONDITIONS PbcV198Tm40_STD_CELL_7RF
    set CELL_LIB_LIST {PbcV198Tm40_STD_CELL_7RF.lib}
} else {
    puts "Corner <${RUN_CORNER}> not recognized. Supported values are \"wc\", \"nc\", \"bc\". FOr further information refer to cell lib README"
    exit
}

#-----------------------------------------------------------------------------
# Load Path Script
#-----------------------------------------------------------------------------
source ${PROJECT_DIR}/trunk/backend/synthesis/scripts/common/path.tcl

#-----------------------------------------------------------------------------
# Load Tech Script
#-----------------------------------------------------------------------------
source ${SCRIPT_DIR}/common/tech.tcl

#-----------------------------------------------------------------------------
# Analyze RTL sources (manually set at file file_list.tcl)
#-----------------------------------------------------------------------------
set_attribute hdl_search_path "${DEV_DIR} ${FRONTEND_DIR}"
source ${SCRIPT_DIR}/file_list.tcl

#-----------------------------------------------------------------------------
# Pre "Elaborate" Attributes (manually set at file attributes.tcl)
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Elaborate Design
#-----------------------------------------------------------------------------
elaborate ${TOP_LVL_ENTITY}
check_design -unresolved ${TOP_LVL_ENTITY}
filter latch true [find / -instance *]

#-----------------------------------------------------------------------------
# Pos "Elaborate" Attributes (manually set)
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Generic optimization (technology independent)
#-----------------------------------------------------------------------------
if {${OPTIMIZE_FLAG} == 1} {
    puts "\n\nPerforming generic synthesis with optimization effort \"high\"\n\n"
    synthesize -to_gen ${TOP_LVL_ENTITY} -effort high ;# timing driven CSA optimization
} else {
    puts "\n\nPerforming generic synthesis with no optimizations\n\n"
    synthesize -to_gen ${TOP_LVL_ENTITY}
}

#-----------------------------------------------------------------------------
# Constraints (multi-mode is not covered in ELC1054)
#-----------------------------------------------------------------------------
read_sdc ${BACKEND_DIR}/synthesis/constraints/default.sdc
set_attribute fixed_slew ${slew} /designs/${TOP_LVL_ENTITY}/ports_in/*
report timing -lint

#-----------------------------------------------------------------------------
# Agressively optimization (area, timing, power) and mapping
#-----------------------------------------------------------------------------
if {${OPTIMIZE_FLAG} == 1} {
    puts "\n\nPerforming mapped synthesis with optimization effort \"high\"\n\n"
    synthesize -to_map ${TOP_LVL_ENTITY} -effort high ;# timing driven CSA optimization
} else {
    puts "\n\nPerforming mapped synthesis with no optimizations\n\n"
    synthesize -to_map ${TOP_LVL_ENTITY}
}

#-----------------------------------------------------------------------------
# Preparing and generating output data (reports, verilog netlist)
#-----------------------------------------------------------------------------
report design_rules > ${DEV_DIR}/${TOP_LVL_ENTITY}_drc.rpt
report area  > ${DEV_DIR}/${TOP_LVL_ENTITY}_area.rpt
report timing > ${DEV_DIR}/${TOP_LVL_ENTITY}_timing.rpt
report gates  > ${DEV_DIR}/${TOP_LVL_ENTITY}_gates.rpt
set_attribute lp_power_analysis_effort high
report power > ${DEV_DIR}/${TOP_LVL_ENTITY}_power_BEFORE_VCD.rpt
write_sdf -edge check_edge -nonegchecks -setuphold split -version 2.1 -design ${TOP_LVL_ENTITY} > ${DEV_DIR}/SDF_FILE.sdf
write_hdl ${TOP_LVL_ENTITY} > ${DEV_DIR}/${TOP_LVL_ENTITY}.v

# Simulates synthesized circuit and generates VCD file if $VCD_SIM_FLAG has been set as "1" by run_synthesis.sh
if {${VCD_SIM_FLAG} == 1} {

    # Calls ncsim with synthesized design
    source ${SCRIPT_DIR}/genVCD.tcl 

    # Analysies power with switching activity information from VCD file generated in previous step and outputs new power report
    read_vcd -vcd_scope DUV ${SYNT_DIR}/work/VCD_FILE.vcd
    #read_vcd -vcd_scope DUV ${DEV_DIR}/VCD_FILE.vcd
    report power > ${DEV_DIR}/${TOP_LVL_ENTITY}_power_AFTER_VCD.rpt
}

