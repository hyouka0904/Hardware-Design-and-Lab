# Run from the repository root:
# vivado -mode batch -source final_project/create_project.tcl -tclargs <build-directory>
if {$argc != 1} {
    error "Usage: vivado -mode batch -source final_project/create_project.tcl -tclargs <build-directory>"
}

set source_dir [file dirname [file normalize [info script]]]
set repo_dir [file dirname $source_dir]
set keyboard_dir [file join $repo_dir ip_lab6 Keyboard-Controller keyboard_cntr_1.0 src]
set build_dir [file normalize [lindex $argv 0]]

create_project escape_from_nthu $build_dir -part xc7a35tcpg236-1
set_property target_language Verilog [current_project]

add_files -norecurse [glob -directory $source_dir *.v]
add_files -norecurse [list [file join $keyboard_dir KeyboardCtrl.v] \
                          [file join $keyboard_dir Ps2Interface.v]]
add_files -fileset constrs_1 -norecurse [file join $source_dir Group09_code.xdc.xdc]
set_property file_type SystemVerilog [get_files [file join $keyboard_dir Ps2Interface.v]]
set_property top final_project [current_fileset]

proc create_video_rom {name depth coe_path} {
    create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name $name
    set ip [get_ips $name]
    set_property -dict [list \
        CONFIG.Memory_Type {Single_Port_ROM} \
        CONFIG.Write_Depth_A $depth \
        CONFIG.Write_Width_A {12} \
        CONFIG.Read_Width_A {12} \
        CONFIG.Enable_A {Use_ENA_Pin} \
        CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
        CONFIG.Register_PortA_Output_of_Memory_Core {false} \
        CONFIG.Load_Init_File {true} \
        CONFIG.Coe_File $coe_path] $ip
    generate_target all $ip
}

create_video_rom blk_mem_gen_0 76800 [file join $source_dir background4.coe]
create_video_rom blk_mem_gen_1 43200 [file join $source_dir alphabet.coe]
update_compile_order -fileset sources_1
