source scripts/config.tcl

create_project vivado_project $PROJ_DIR -part $PART_NAME
add_files -fileset constrs_1 $CONSTRAINT
add_files $SRC_FILES
set_property top $TOP [current_fileset]
