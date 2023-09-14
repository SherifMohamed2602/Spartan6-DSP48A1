vlib work 

vlog DSP.v Reg_Mux_Pair.v DSP_GOLDEN_MODEL.v DSP_tb.v

vsim -voptargs=+acc work.DSP48A1_tb

add wave *

run -all

