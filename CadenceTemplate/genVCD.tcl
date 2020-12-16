
puts "Begin generating VCD file"

# Defines cell library directory
set CellLibDIR ${TECH_DIR}/IBM_PDK/cmrf7sf/V2.0.0.2AM/ibm_cmos7rf_std_cell_20111130/std_cell/v.20111130/verilog

# Compiles cell library
puts "Compiling cell library"
#exec ncvlog {*}[glob ${CellLibDIR}/*.v]; #-vtimescale 1ns/1ps
exec ncvlog {*}[glob ${CellLibDIR}/*.v] -vtimescale 1ns/1ps

# Compiles synthesized design
puts "Compiling synthesized design"
#exec ncvlog ${DEV_DIR}/${TOP_LVL_ENTITY}.v; #-vtimescale 1ns/1ps
exec ncvlog ${DEV_DIR}/${TOP_LVL_ENTITY}.v -vtimescale 1ns/1ps

# Compiles testbench
puts "Compiling testbench"
exec ncvhdl -v93 ${PROJECT_DIR}/trunk/frontend/array_pkg.vhd 
exec ncvhdl -v93 ${PROJECT_DIR}/trunk/frontend/testbench.vhd

# Compiles SDF file. Outputs file "${DEV_DIR}/SDF_FILE.sdf.X", which should be passed to ncelab
puts "Compiling SDF file"
exec ncsdfc -compile ${DEV_DIR}/SDF_FILE.sdf 

# Elaborates testbench
puts "Elaborating testbench"
exec ncelab -messages -libverbose -status -nomxindr -access +rwc -sdf_cmd_file ${PROJECT_DIR}/trunk/frontend/sdf_cmd_file.cmd work.testbench

# Calling simulator
puts "Begining simulation"
exec ncsim work.testbench -input ${SCRIPT_DIR}/genVCD_NCSIM.in

# Returns to RTL Compiler
puts "VCD generated"

