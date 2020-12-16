include load_etc.tcl 

#-----------------------------------------------------------------------------
# LEF Files and Technology Library
#-----------------------------------------------------------------------------
set_attribute lib_search_path "${LIB_DIR} ${LEF_DIR}"

#create_library_domain {worst best} ;# needs license RTL_Compiler_Ultra_II_Option

#set_attribute library ${WORST_LIST}
set_attribute library ${CELL_LIB_LIST}
#set_attribute library ${WORST_LIST} [find -library_domain worst]
#set_attribute library ${BEST_LIST} [find -library_domain best]

# for information only
get_att active_operating_conditions
#get_att active_operating_conditions [find -library_domain worst]
#get_attribute default [find /libraries -library_domain worst]

# Choose library domain to perform optimization
#set_attribute default true [find /libraries -library_domain worst]
#set_attribute default true [find /libraries -library_domain best]

# Load lef files
set_attribute lef_library ${LEF_LIST}

# Use PLE mode
set_attribute interconnect_mode ${INTERCONNECT_MODE}

#-----------------------------------------------------------------------------
# Manage Cells
#-----------------------------------------------------------------------------
# Try to save power; gated clock cells: 
#ls /libraries/PwcV162T125_STD_CELL_7RF/libcells/
#set_attribute avoid true /libraries/PwcV162T125_STD_CELL_7RF/libcells/????*
# Avoid scan flip-flops: 
#ls /libraries/PwcV162T125_STD_CELL_7RF/libcells/
#set_attribute avoid true /libraries/PwcV162T125_STD_CELL_7RF/libcells/SDF*

if {$RUN_CORNER == "wc"} {  ;# Worst case (1.62V @ 125C)
    ls /libraries/PwcV162T125_STD_CELL_7RF/libcells/
    set_attribute avoid true /libraries/PwcV162T125_STD_CELL_7RF/libcells/SDF*
} elseif {$RUN_CORNER == "nc"} {  ;# Nominal case (1.8V @ 25C)
    ls /libraries/PnomV180T025_STD_CELL_7RF/libcells/
    set_attribute avoid true /libraries/PnomV180T025_STD_CELL_7RF/libcells/SDF*
} elseif {$RUN_CORNER == "bc"} {  ;# Best case (1.98V @ -40C)
    ls /libraries/PbcV198Tm40_STD_CELL_7RF/libcells/
    set_attribute avoid true /libraries/PbcV198Tm40_STD_CELL_7RF/libcells/SDF*
}

