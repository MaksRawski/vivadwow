# basics taken from: https://grittyengineer.com/vivado-project-mode-tcl-script/
# but to get it to work i used: https://surf-vhdl.com/tcl-script-vivado-project-tutorial

source scripts/config.tcl

# create the project itself
create_project $PROJ_NAME $BUILD_DIR -part $PART_NAME
add_files $SRC_FILES
# add_files -fileset sim_1 $TB_FILES
add_files -fileset constrs_1 $CONSTRAINT
import_files -force

# set top module
set_property top $TOP_MODULE [current_fileset]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
