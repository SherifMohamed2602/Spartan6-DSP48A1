vlib work 

vlog PROJECT1.v Reg_Mux_Pair.v PROJECT1_GOLD.v Project1_tb.v

vsim -voptargs=+acc work.DSP48A1_tb

add wave *

run -all

