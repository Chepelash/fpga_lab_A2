transcript on


vlib work

vlog -sv ../src/serializer.sv
vlog -sv ./serializer_tb.sv

vsim -novopt serializer_tb

add wave /serializer_tb/clk
add wave /serializer_tb/rst
add wave /serializer_tb/data_val_i
add wave /serializer_tb/data_mod_i
add wave /serializer_tb/data_i
add wave /serializer_tb/ser_data_val_o
add wave /serializer_tb/ser_data_o
add wave /serializer_tb/busy_o

run -all

