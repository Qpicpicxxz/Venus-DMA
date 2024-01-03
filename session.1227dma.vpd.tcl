# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Dec 27 18:45:45 2023
# Designs open: 1
#   Sim: dma_tb
# Toplevel windows open: 3
# 	TopLevel.1
# 	TopLevel.2
# 	TopLevel.3
#   Source.1: dma_tb.u_dma.u_dma_axi_if
#   Wave.1: 61 signals
#   Wave.2: 1 signals
#   Group count = 8
#   Group u_dma signal count = 2
#   Group u_dma_fsm signal count = 14
#   Group u_dma_rd_streamer signal count = 9
#   Group u_dma_fifo signal count = 19
#   Group u_dma_fifo_1 signal count = 10
#   Group u_dma_wr_streamer signal count = 8
#   Group u_dma_axi_if signal count = 20
#   Group u_dma_axi_if_1 signal count = 1
# End_DVE_Session_Save_Info

# DVE version: O-2018.09-SP2-11_Full64
# DVE build date: Feb 13 2020 21:30:28


#<Session mode="Full" path="/home/dengqingyu/1222_dma/session.1227dma.vpd.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{0 65} {1511 905}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 358]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
catch { set Stack.1 [gui_share_window -id ${HSPane.1} -type Stack -silent] }
catch { set Class.1 [gui_share_window -id ${HSPane.1} -type Class -silent] }
catch { set Object.1 [gui_share_window -id ${HSPane.1} -type Object -silent] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 358
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 357} {height 381} {dock_state left} {dock_on_new_line true} {child_hier_colhier 419} {child_hier_coltype 59} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 205]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
catch { set Local.1 [gui_share_window -id ${DLPane.1} -type Local -silent] }
catch { set Member.1 [gui_share_window -id ${DLPane.1} -type Member -silent] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 205
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 379
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 204} {height 381} {dock_state left} {dock_on_new_line true} {child_data_colvariable 242} {child_data_colvalue 125} {child_data_coltype 105} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 346]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value -1
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 346
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 307} {height 345} {dock_state bottom} {dock_on_new_line true}}
set DriverLoad.1 [gui_create_window -type DriverLoad -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line false -dock_extent 180]
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_width -value_type integer -value 150
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_height -value_type integer -value 180
gui_set_window_pref_key -window ${DriverLoad.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DriverLoad.1} {{left 0} {top 0} {width 1203} {height 345} {dock_state bottom} {dock_on_new_line false}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{60 66} {1571 906}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 438} {child_wave_right 1068} {child_wave_colname 217} {child_wave_colvalue 217} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings


# Create and position top-level window: TopLevel.3

if {![gui_exist_window -window TopLevel.3]} {
    set TopLevel.3 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.3 TopLevel.3
}
gui_show_window -window ${TopLevel.3} -show_state maximized -rect {{60 66} {1571 906}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.3} -option true

# MDI window settings
set Wave.2 [gui_create_window -type {Wave}  -parent ${TopLevel.3}]
gui_show_window -window ${Wave.2} -show_state maximized
gui_update_layout -id ${Wave.2} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 438} {child_wave_right 1068} {child_wave_colname 208} {child_wave_colvalue 226} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}
gui_update_statusbar_target_frame ${TopLevel.2}
gui_update_statusbar_target_frame ${TopLevel.3}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{ +vpdfile+dma_tb.vpd -ucligui}}
gui_set_env SIMSETUP::SIMEXE {dma_tb}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {dma_tb}] } {
gui_sim_run Ucli -exe dma_tb -args { +vpdfile+dma_tb.vpd -ucligui} -dir ../1222_dma -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 1ps
gui_set_time_units 1ps
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {dma_tb.u_dma.u_dma_fifo}


set _session_group_1 u_dma
gui_sg_create "$_session_group_1"
set u_dma "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { dma_tb.u_dma.clear_dma dma_tb.u_dma.rst }

set _session_group_2 u_dma_fsm
gui_sg_create "$_session_group_2"
set u_dma_fsm "$_session_group_2"

gui_sg_addsignal -group "$_session_group_2" { dma_tb.u_dma.u_dma_fsm.clk dma_tb.u_dma.u_dma_fsm.dma_go_i dma_tb.u_dma.u_dma_fsm.cur_st_ff dma_tb.u_dma.u_dma_fsm.dma_stats_o dma_tb.u_dma.u_dma_fsm.dma_active_o dma_tb.u_dma.u_dma_fsm.clear_dma_o dma_tb.u_dma.u_dma_fsm.axi_pend_txn_i dma_tb.u_dma.u_dma_fsm.pending_rd_desc dma_tb.u_dma.u_dma_fsm.rd_desc_done_ff dma_tb.u_dma.u_dma_fsm.dma_stream_rd_done_i dma_tb.u_dma.u_dma_fsm.dma_stream_rd_valid_o dma_tb.u_dma.u_dma_fsm.wr_desc_done_ff dma_tb.u_dma.u_dma_fsm.dma_stream_wr_done_i dma_tb.u_dma.u_dma_fsm.dma_stream_wr_valid_o }

set _session_group_3 u_dma_rd_streamer
gui_sg_create "$_session_group_3"
set u_dma_rd_streamer "$_session_group_3"

gui_sg_addsignal -group "$_session_group_3" { dma_tb.u_dma.u_dma_rd_streamer.dma_stream_valid_i dma_tb.u_dma.u_dma_rd_streamer.dma_stream_done_o dma_tb.u_dma.u_dma_rd_streamer.cur_st_ff dma_tb.u_dma.u_dma_rd_streamer.last_txn_ff dma_tb.u_dma.u_dma_rd_streamer.desc_bytes_ff dma_tb.u_dma.u_dma_rd_streamer.desc_addr_ff dma_tb.u_dma.u_dma_rd_streamer.dma_req_ff dma_tb.u_dma.u_dma_rd_streamer.dma_axi_req_o dma_tb.u_dma.u_dma_rd_streamer.dma_axi_resp_i }

set _session_group_4 u_dma_fifo
gui_sg_create "$_session_group_4"
set u_dma_fifo "$_session_group_4"

gui_sg_addsignal -group "$_session_group_4" { dma_tb.u_dma.u_dma_fifo.min_fifo_size dma_tb.u_dma.u_dma_fifo.illegal_fifo_slot dma_tb.u_dma.u_dma_fifo.read_i dma_tb.u_dma.u_dma_fifo.SLOTS dma_tb.u_dma.u_dma_fifo.full_o dma_tb.u_dma.u_dma_fifo.empty_o dma_tb.u_dma.u_dma_fifo.fifo_ff dma_tb.u_dma.u_dma_fifo.next_write_ptr dma_tb.u_dma.u_dma_fifo.data_i dma_tb.u_dma.u_dma_fifo.next_read_ptr dma_tb.u_dma.u_dma_fifo.clear_i dma_tb.u_dma.u_dma_fifo.data_o dma_tb.u_dma.u_dma_fifo.write_i axi_pkg.DATA_BUS_WIDTH dma_tb.u_dma.u_dma_fifo.clk dma_tb.u_dma.u_dma_fifo.WIDTH dma_tb.u_dma.u_dma_fifo.read_ptr_ff dma_tb.u_dma.u_dma_fifo.write_ptr_ff dma_tb.u_dma.u_dma_fifo.rst }
gui_set_radix -radix {decimal} -signals {Sim:dma_tb.u_dma.u_dma_fifo.SLOTS}
gui_set_radix -radix {twosComplement} -signals {Sim:dma_tb.u_dma.u_dma_fifo.SLOTS}
gui_set_radix -radix {decimal} -signals {Sim:axi_pkg.DATA_BUS_WIDTH}
gui_set_radix -radix {twosComplement} -signals {Sim:axi_pkg.DATA_BUS_WIDTH}
gui_set_radix -radix {decimal} -signals {Sim:dma_tb.u_dma.u_dma_fifo.WIDTH}
gui_set_radix -radix {twosComplement} -signals {Sim:dma_tb.u_dma.u_dma_fifo.WIDTH}

set _session_group_5 u_dma_fifo_1
gui_sg_create "$_session_group_5"
set u_dma_fifo_1 "$_session_group_5"

gui_sg_addsignal -group "$_session_group_5" { dma_tb.u_dma.u_dma_fifo.read_i dma_tb.u_dma.u_dma_fifo.clear_i dma_tb.u_dma.u_dma_fifo.write_i dma_tb.u_dma.u_dma_fifo.data_i dma_tb.u_dma.u_dma_fifo.data_o dma_tb.u_dma.u_dma_fifo.fifo_ff dma_tb.u_dma.u_dma_fifo.empty_o dma_tb.u_dma.u_dma_fifo.full_o dma_tb.u_dma.u_dma_fifo.write_ptr_ff dma_tb.u_dma.u_dma_fifo.read_ptr_ff }

set _session_group_6 u_dma_wr_streamer
gui_sg_create "$_session_group_6"
set u_dma_wr_streamer "$_session_group_6"

gui_sg_addsignal -group "$_session_group_6" { dma_tb.u_dma.u_dma_wr_streamer.dma_stream_valid_i dma_tb.u_dma.u_dma_wr_streamer.dma_stream_done_o dma_tb.u_dma.u_dma_wr_streamer.cur_st_ff dma_tb.u_dma.u_dma_wr_streamer.desc_bytes_ff dma_tb.u_dma.u_dma_wr_streamer.desc_addr_ff dma_tb.u_dma.u_dma_wr_streamer.dma_req_ff dma_tb.u_dma.u_dma_wr_streamer.dma_axi_req_o dma_tb.u_dma.u_dma_wr_streamer.dma_axi_resp_i }

set _session_group_7 u_dma_axi_if
gui_sg_create "$_session_group_7"
set u_dma_axi_if "$_session_group_7"

gui_sg_addsignal -group "$_session_group_7" { dma_tb.u_dma.u_dma_axi_if.dma_active_i dma_tb.u_dma.u_dma_axi_if.clear_dma_i dma_tb.u_dma.u_dma_axi_if.axi_req_o dma_tb.u_dma.u_dma_axi_if.axi_resp_i dma_tb.u_dma.u_dma_axi_if.axi_pend_txn_o dma_tb.u_dma.u_dma_axi_if.rd_txn_hpn dma_tb.u_dma.u_dma_axi_if.rd_resp_hpn dma_tb.u_dma.u_dma_axi_if.wr_txn_hpn dma_tb.u_dma.u_dma_axi_if.wr_resp_hpn dma_tb.u_dma.u_dma_axi_if.aw_txn_started_ff dma_tb.u_dma.u_dma_axi_if.rd_txn_req_ff dma_tb.u_dma.u_dma_axi_if.wr_txn_req_ff dma_tb.u_dma.u_dma_axi_if.dma_fifo_req_o dma_tb.u_dma.u_dma_axi_if.dma_fifo_resp_i dma_tb.u_dma.u_dma_axi_if.dma_axi_rd_req_i dma_tb.u_dma.u_dma_axi_if.dma_axi_rd_resp_o dma_tb.u_dma.u_dma_axi_if.dma_axi_wr_req_i dma_tb.u_dma.u_dma_axi_if.dma_axi_wr_resp_o dma_tb.u_dma.u_dma_axi_if.wr_beat_hpn dma_tb.u_dma.u_dma_axi_if.beat_counter_ff }

set _session_group_8 u_dma_axi_if_1
gui_sg_create "$_session_group_8"
set u_dma_axi_if_1 "$_session_group_8"

gui_sg_addsignal -group "$_session_group_8" { dma_tb.u_dma.u_dma_axi_if.clk }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 356000



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} dma_tb}
catch {gui_list_expand -id ${Hier.1} dma_tb.u_dma}
catch {gui_list_select -id ${Hier.1} {dma_tb.u_dma.u_dma_axi_if}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Class 'Class.1'
gui_list_set_filter -id ${Class.1} -list { {OVM 1} {VMM 1} {All 1} {Object 1} {UVM 1} {RVM 1} }
gui_list_set_filter -id ${Class.1} -text {*}
gui_change_design -id ${Class.1} -design Sim
# Warning: Class view not found.

# Member 'Member.1'
gui_list_set_filter -id ${Member.1} -list { {InternalMember 0} {RandMember 1} {All 0} {BaseMember 0} {PrivateMember 1} {LibBaseMember 0} {AutomaticMember 1} {VirtualMember 1} {PublicMember 1} {ProtectedMember 1} {OverRiddenMember 0} {InterfaceClassMember 1} {StaticMember 1} }
gui_list_set_filter -id ${Member.1} -text {*}

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {dma_tb.u_dma.u_dma_axi_if}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active dma_tb.u_dma.u_dma_axi_if rtl/dma/dma_axi_if.sv
gui_view_scroll -id ${Source.1} -vertical -set 3040
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 311723 401324
gui_list_add_group -id ${Wave.1} -after {New Group} {u_dma_fsm}
gui_list_add_group -id ${Wave.1} -after {New Group} {u_dma_rd_streamer}
gui_list_add_group -id ${Wave.1} -after {New Group} {u_dma_fifo_1}
gui_list_add_group -id ${Wave.1} -after {New Group} {u_dma_wr_streamer}
gui_list_add_group -id ${Wave.1} -after {New Group} {u_dma_axi_if}
gui_list_collapse -id ${Wave.1} u_dma_fsm
gui_list_collapse -id ${Wave.1} u_dma_rd_streamer
gui_list_collapse -id ${Wave.1} u_dma_fifo_1
gui_list_collapse -id ${Wave.1} u_dma_wr_streamer
gui_list_expand -id ${Wave.1} dma_tb.u_dma.u_dma_axi_if.axi_req_o
gui_list_expand -id ${Wave.1} dma_tb.u_dma.u_dma_axi_if.dma_fifo_resp_i
gui_list_expand -id ${Wave.1} dma_tb.u_dma.u_dma_axi_if.dma_axi_wr_req_i
gui_list_select -id ${Wave.1} {dma_tb.u_dma.u_dma_axi_if.axi_req_o.awvalid }
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group u_dma_axi_if  -item {dma_tb.u_dma.u_dma_axi_if.beat_counter_ff[7:0]} -position below

gui_marker_move -id ${Wave.1} {C1} 356000
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false

# DriverLoad 'DriverLoad.1'
gui_get_drivers -session -id ${DriverLoad.1} -signal dma_tb.u_dma.u_dma_fsm.dma_stream_rd_done_i -time 404000 -starttime 684000
gui_get_drivers -session -id ${DriverLoad.1} -signal {dma_tb.u_dma.u_dma_wr_streamer.cur_st_ff[0:0]} -time 410000 -starttime 684000
gui_get_drivers -session -id ${DriverLoad.1} -signal dma_tb.u_dma.u_dma_axi_if.dma_fifo_req_o -time 474000 -starttime 684000

# View 'Wave.2'
gui_wv_sync -id ${Wave.2} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.2}  C1
gui_wv_zoom_timerange -id ${Wave.2} 0 349
gui_list_add_group -id ${Wave.2} -after {New Group} {u_dma_axi_if_1}
gui_list_select -id ${Wave.2} {dma_tb.u_dma.u_dma_axi_if.clk }
gui_seek_criteria -id ${Wave.2} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.2}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.2} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.2} -text {*}
gui_list_set_insertion_bar  -id ${Wave.2} -group u_dma_axi_if_1  -item dma_tb.u_dma.u_dma_axi_if.clk -position below

gui_marker_move -id ${Wave.2} {C1} 356000
gui_view_scroll -id ${Wave.2} -vertical -set 0
gui_show_grid -id ${Wave.2} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
if {[gui_exist_window -window ${TopLevel.3}]} {
	gui_set_active_window -window ${TopLevel.3}
	gui_set_active_window -window ${Wave.2}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

