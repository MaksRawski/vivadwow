set SRC_DIR src
set BUILD_DIR build
set TOP_MODULE top

set PART_NAME xc7s50csga324-1
set CONSTRAINT Arty-S7-50.xdc

set SRC_FILES [lsearch -inline -not -glob [glob "$SRC_DIR/*.*"] "$SRC_DIR/*_tb.*"]
