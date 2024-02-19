source scripts/config.tcl

report_clock_utilization -file $BUILD_DIR/reports/clock_util.rpt
report_utilization -file $BUILD_DIR/reports/post_impl_util.rpt
report_timing_summary -file $BUILD_DIR/reports/post_impl_timing_summary.rpt

report_route_status -file $BUILD_DIR/reports/post_impl_status.rpt
report_timing_summary -file $BUILD_DIR/reports/post_impl_timing_summary.rpt
report_power -file $BUILD_DIR/reports/post_impl_power.rpt
report_drc -file $BUILD_DIR/reports/post_impl_drc.rpt
