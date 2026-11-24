# Run from the extracted repository folder in Vivado Tcl Console.
set PROJECT_NAME "configurable_pwm_artix7"
set PART "xc7a35tcpg236-1"

create_project $PROJECT_NAME ./$PROJECT_NAME -part $PART -force

add_files ./rtl/configurable_pwm_generator.v
add_files -fileset sim_1 ./sim/tb_configurable_pwm_generator.v
add_files -fileset constrs_1 ./constraints/artix7_template.xdc

set_property top configurable_pwm_generator [current_fileset]
set_property top tb_configurable_pwm_generator [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Vivado project created."
puts "Verify PART against the exact FPGA part number on your Artix-7 board."
puts "Use tb_configurable_pwm_generator for behavioral simulation."
