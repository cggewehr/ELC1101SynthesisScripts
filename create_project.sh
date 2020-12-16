#!/bin/bash

if [ -z $1 ]
then
	echo "usage: sh create_project.sh [project dir]"
	exit 1
fi

#mkdir -p ~/Desktop/$1/trunk/backend/synthesis/work
#mkdir -p ~/Desktop/$1/trunk/backend/synthesis/constraints
#cp ~/scripts/default.sdc ~/Desktop/$1/trunk/backend/synthesis/constraints
#mkdir  -p ~/Desktop/$1/trunk/frontend/tests
#mkdir -p ~/Desktop/$1/trunk/backend/synthesis/scripts/common
#cp ~/scripts/path.tcl ~/scripts/tech.tcl ~/Desktop/$1/trunk/backend/synthesis/scripts/common
#cp ~/scripts/generic_logic_synthesis.tcl ~/Desktop/$1/trunk/backend/synthesis/scripts/

PROJECT_DIR=$1

echo "Creating Cadence project at \"$PROJ_DIR\""

# Creates directory structure
mkdir -p $PROJECT_DIR/trunk/backend/synthesis/constraints
#mkdir -p $PROJECT_DIR/trunk/backend/synthesis/deliverables
mkdir -p $PROJECT_DIR/trunk/backend/synthesis/work
mkdir -p $PROJECT_DIR/trunk/backend/synthesis/scripts/common
mkdir -p $PROJECT_DIR/trunk/frontend

# Copies files from template DIR
TEMPLATE_DIR="/home/usr/cgewehr/Desktop/CadenceTemplate"
echo "Copying template files from \"$TEMPLATE_DIR\""

cp ${TEMPLATE_DIR}/RTLCompiler.tcl ${PROJECT_DIR}/trunk/backend/synthesis/scripts/
cp ${TEMPLATE_DIR}/genVCD.tcl ${PROJECT_DIR}/trunk/backend/synthesis/scripts/
cp ${TEMPLATE_DIR}/path.tcl ${PROJECT_DIR}/trunk/backend/synthesis/scripts/common/
cp ${TEMPLATE_DIR}/tech.tcl ${PROJECT_DIR}/trunk/backend/synthesis/scripts/common/
cp ${TEMPLATE_DIR}/default.sdc ${PROJECT_DIR}/trunk/backend/synthesis/constraints/
cp ${TEMPLATE_DIR}/file_list.tcl ${PROJECT_DIR}/trunk/backend/synthesis/scripts/
cp ${TEMPLATE_DIR}/genVCD_NCSIM.in ${PROJECT_DIR}/trunk/backend/synthesis/scripts/

# Writes SDF command file
SDF_FILE=$PROJECT_DIR/trunk/frontend/sdf_cmd_file.cmd

#// SDF command file /home/tools/docencia_elc1054/docencia/somador/trunk/frontend/sdf_cmd_file.cmd

#COMPILED_SDF_FILE = "/home/tools/docencia_elc1054/docencia/somador/trunk/backend/synthesis/deliverables/somador_normal_worst.sdf.X",
#SCOPE = :DUV,
#LOG_FILE = "sdf.log",
#MTM_CONTROL = "MAXIMUM",
#SCALE_FACTORS = "1.0:1.0:1.0",
#SCALE_TYPE = "FROM_MTM";

#// END OF FILE: /home/tools/docencia_elc1054/docencia/somador/trunk/frontend/sdf_cmd_file.cmd

echo "// SDF command file $PROJECT_DIR/trunk/frontend/sdf_cmd_file.cmd" > $SDF_FILE
echo "" >> $SDF_FILE
echo "COMPILED_SDF_FILE = \"$PROJECT_DIR/trunk/backend/synthesis/deliverables/SDF_FILE.sdf.X\"," >> $SDF_FILE
echo "SCOPE = :DUV," >> $SDF_FILE
echo "LOG_FILE = \"sdf.log\"," >> $SDF_FILE
echo "MTM_CONTROL = \"MAXIMUM\"," >> $SDF_FILE
echo "SCALE_FACTORS = \"1.0:1.0:1.0\"," >> $SDF_FILE
echo "SCALE_TYPE = \"FROM_MTM\";" >> $SDF_FILE
echo "" >> $SDF_FILE
echo "// END OF FILE: $PROJECT_DIR/trunk/frontend/sdf_cmd_file.cmd" >> $SDF_FILE

echo "Cadence project created at \"$PROJECT_DIR\""

