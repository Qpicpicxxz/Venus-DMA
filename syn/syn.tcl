set systemTime [clock seconds]
set time [clock format $systemTime -format %b%d%Y_%H%M%S]

proc procVHDLFileList {fileList rtlPath} {
	set f [open $fileList r]
	set rtlFile ""
	set keyMap {$RTL}
	while { [gets $f data] >= 0 } {
		#echo $data
	  set rtlFile [concat  [list] $rtlFile [string map "$keyMap $rtlPath" $data] ]
	}
	close $f
	return $rtlFile
}


proc createDivClk {label src obj ratio} {
	create_generated_clock -name $label -divide_by $ratio -source $src $obj
	#set_dont_touch $obj
	set_ideal_network $obj
}

proc createClk {clkName clkPeriod clkObj clkUncertainty} {
	create_clock -name $clkName -period $clkPeriod  $clkObj
	set_clock_uncertainty -setup $clkUncertainty $clkName
	set_clock_uncertainty -hold $clkUncertainty $clkName
	set_ideal_network $clkObj

}

proc listMemoryDB {path corner temp} {
	return [exec find $path -name "*_${corner}_*$temp*.db"]
}

set RTL "."

set_host_options -max_cores 16

set search_path  [concat  [list] . \
			/home/ASIC_lib/SMIC40/arm/smic/logic0040ll/sc9mc_base_hvt_c50/r0p0/db/	\
			/home/ASIC_lib/SMIC40/arm/smic/logic0040ll/sc9mc_base_lvt_c40/r0p2/db/	\
			/home/ASIC_lib/SMIC40/arm/smic/logic0040ll/sc9mc_base_lvt_c50/r0p2/db/	\
			/home/ASIC_lib/SMIC40/arm/smic/logic0040ll/sc9mc_base_rvt_c40/r1p2/db/	\
			/home/ASIC_lib/SMIC40/arm/smic/logic0040ll/sc9mc_base_rvt_c50/r1p2/db/	\
			$search_path ]

set memory_db [listMemoryDB "../rtl/output_db" "ss" "125c"]
			
set target_library [concat sc9mc_logic0040ll_base_hvt_c50_ss_typical_max_0p99v_125c.db \
                           sc9mc_logic0040ll_base_rvt_c50_ss_typical_max_0p99v_125c.db \
                           sc9mc_logic0040ll_base_rvt_c40_ss_typical_max_0p99v_125c.db \
                           sc9mc_logic0040ll_base_lvt_c50_ss_typical_max_0p99v_125c.db \
                           sc9mc_logic0040ll_base_lvt_c40_ss_typical_max_0p99v_125c.db \
						   $memory_db ]

set synthetic_library dw_foundation.sldb

set link_library [concat * $target_library $synthetic_library ]


# #signed to unsigned assignment occurs. (VER-318)
# #DEFAULT branch of CASE statement cannot be reached. (ELAB-311)
# #suppress_message {LINT-33 LINT-1 LINT-32 VER-944 ELAB-311 VER-318 TIM-175 UID-401}

# #The initial value for signal 'xxx' is not supported for synthesis. Presto ignores it.  (ELAB-130)
# #The port default value in entity declaration for port 'SSET' is not supported. Presto ignores it. (ELAB-802)
# suppress_message {ELAB-130 ELAB-802}

set verilogout_no_tri true
set link_force_case    case_insensitive
set verilogout_equation  false

set vhdlout_single_bit user

# report_timing -from [get_pin u_venus_ext/gen_lanes[7].u_lane/u_vfu/u_cau_wrap/result_queue_read_pnt_q_reg[0]/CK] -to [get_pin {u_venus_ext/gen_lanes[7].u_lane/u_operand_requester/gen_operand_requester[0].requester_q_reg[hazard][0]/D}] -capacitance -transition_time
# report_timing -from [get_pin u_vfu/u_cau_wrap/result_queue_read_pnt_q_reg[0]/CK] -to [get_pin {u_operand_requester/gen_operand_requester[0].requester_q_reg[hazard][0]/D}] -capacitance -transition_time

set designTop dma_func_wrapper
set tcl_top syn_dir

exec rm -rf ./$tcl_top
exec mkdir ./$tcl_top
define_design_lib work -path ./$tcl_top/lib/work
exec rm -rf ./$tcl_top/lib
exec rm -rf ./$tcl_top/lib/work
exec mkdir ./$tcl_top/lib
exec mkdir ./$tcl_top/lib/work
exec mkdir ./$tcl_top/report

analyze -vcs "-sverilog -f ./filelist.f" > $tcl_top/analyze_v.log
# set rtl_vhdl  [procVHDLFileList "$RTL/filelist_vhd.f" "$RTL"] 
# analyze -format vhdl -lib work  $rtl_vhdl   > analyze_vhdl.log

elaborate  -library work "$designTop"  > $tcl_top/elaborate.log
current_design  "$designTop"
uniquify
link > $tcl_top/link.log
check_design > $tcl_top/check_design.log

write -hierarchy -format ddc -output $tcl_top/top_pad.ddc


set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
# set_operating_conditions ss_typical_max_0p99v_125c -library sc9mc_logic0040ll_base_rvt_c50_ss_typical_max_0p99v_125c
set_max_area 0
# set_wire_load_mode segmented
set_wire_load_model -name Zero -library sc9mc_logic0040ll_base_rvt_c50_ss_typical_max_0p99v_125c


# constraints
createClk "clk" 3 [get_ports clk] [expr 3*0.1]

set_ideal_network [get_ports rstn]
set_input_delay -clock clk -max [expr 3*0.1] [remove_from_collection [all_inputs] [get_ports clk]] 
set_output_delay -clock clk -max [expr 3*0.1] [all_outputs]

group_path -name clk -weight 5
group_path -name inout -from [all_inputs] -to [all_outputs]
group_path -name inreg -from [all_inputs]
group_path -name regout -to [all_outputs]

set set_isolate_ports true  
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
set_fix_multiple_port_nets -all -buffer_constants
# set_register_merging [get_designs *] false
# set_ungroup [get_designs *] false
# ungroup -all -flatten

set_svf $tcl_top/$designTop.svf
# compile_ultra -gate_clock -no_seq_output_inversion -no_autoungroup
compile_ultra -no_seq_output_inversion
# compile_ultra -incremental -retime -no_seq_output_inversion
set_svf -off
create_block_abstraction
write_file -hierarchy -format ddc -output $tcl_top/$designTop\_hier.ddc
change_names -hierarchy -rules verilog -log_changes $tcl_top/change_names.log
write -hierarchy -format verilog -output $tcl_top/$designTop\_netlist_hier.v
write_sdc $tcl_top/$designTop\_hier.sdc
write_sdf $tcl_top/$designTop\_hier.sdf
report_constraint -verbose -all > $tcl_top/report/constraint.rpt
report_timing -cap -trans -nets > $tcl_top/report/timing.rpt
report_timing -nets -delay_type min > $tcl_top/report/timing_min.rpt
report_power > $tcl_top/report/power.rpt
report_area -hierarchy > $tcl_top/report/area.rpt

exit
