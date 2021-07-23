onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /led_breathing_tb/DUT/clk
add wave -noupdate /led_breathing_tb/DUT/rst_n
add wave -noupdate /led_breathing_tb/DUT/rst
add wave -noupdate -radix unsigned -childformat {{/led_breathing_tb/DUT/cnt(15) -radix unsigned} {/led_breathing_tb/DUT/cnt(14) -radix unsigned} {/led_breathing_tb/DUT/cnt(13) -radix unsigned} {/led_breathing_tb/DUT/cnt(12) -radix unsigned} {/led_breathing_tb/DUT/cnt(11) -radix unsigned} {/led_breathing_tb/DUT/cnt(10) -radix unsigned} {/led_breathing_tb/DUT/cnt(9) -radix unsigned} {/led_breathing_tb/DUT/cnt(8) -radix unsigned} {/led_breathing_tb/DUT/cnt(7) -radix unsigned} {/led_breathing_tb/DUT/cnt(6) -radix unsigned} {/led_breathing_tb/DUT/cnt(5) -radix unsigned} {/led_breathing_tb/DUT/cnt(4) -radix unsigned} {/led_breathing_tb/DUT/cnt(3) -radix unsigned} {/led_breathing_tb/DUT/cnt(2) -radix unsigned} {/led_breathing_tb/DUT/cnt(1) -radix unsigned} {/led_breathing_tb/DUT/cnt(0) -radix unsigned}} -subitemconfig {/led_breathing_tb/DUT/cnt(15) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(14) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(13) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(12) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(11) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(10) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(9) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(8) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(7) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(6) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(5) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(4) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(3) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(2) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(1) {-height 30 -radix unsigned} /led_breathing_tb/DUT/cnt(0) {-height 30 -radix unsigned}} /led_breathing_tb/DUT/cnt
add wave -noupdate /led_breathing_tb/DUT/led_5
add wave -noupdate -format Analog-Step -height 256 -max 255.0 -radix unsigned /led_breathing_tb/DUT/duty_cycle
add wave -noupdate -expand -group SINE_ROM /led_breathing_tb/DUT/SINE_ROM/clk
add wave -noupdate -expand -group SINE_ROM /led_breathing_tb/DUT/SINE_ROM/addr
add wave -noupdate -expand -group SINE_ROM /led_breathing_tb/DUT/SINE_ROM/data
add wave -noupdate -group RESET /led_breathing_tb/DUT/RESET/clk
add wave -noupdate -group RESET /led_breathing_tb/DUT/RESET/rst_n
add wave -noupdate -group RESET /led_breathing_tb/DUT/RESET/rst
add wave -noupdate -group RESET /led_breathing_tb/DUT/RESET/sreg
add wave -noupdate -group RESET /led_breathing_tb/DUT/RESET/clk
add wave -noupdate -group RESET /led_breathing_tb/DUT/RESET/rst_n
add wave -noupdate -group RESET /led_breathing_tb/DUT/RESET/rst
add wave -noupdate -group RESET /led_breathing_tb/DUT/RESET/sreg
add wave -noupdate -group PWM /led_breathing_tb/DUT/PWM/clk
add wave -noupdate -group PWM /led_breathing_tb/DUT/PWM/rst
add wave -noupdate -group PWM /led_breathing_tb/DUT/PWM/duty_cycle
add wave -noupdate -group PWM -radix unsigned /led_breathing_tb/DUT/PWM/pwm_out
add wave -noupdate -group PWM -radix unsigned /led_breathing_tb/DUT/PWM/pwm_cnt
add wave -noupdate -group PWM -radix unsigned /led_breathing_tb/DUT/PWM/clk_cnt
add wave -noupdate -group PWM /led_breathing_tb/DUT/PWM/clk
add wave -noupdate -group PWM /led_breathing_tb/DUT/PWM/rst
add wave -noupdate -group PWM /led_breathing_tb/DUT/PWM/duty_cycle
add wave -noupdate -group PWM -radix unsigned /led_breathing_tb/DUT/PWM/pwm_out
add wave -noupdate -group PWM -radix unsigned /led_breathing_tb/DUT/PWM/pwm_cnt
add wave -noupdate -group PWM -radix unsigned /led_breathing_tb/DUT/PWM/clk_cnt
add wave -noupdate -group COUNTER /led_breathing_tb/DUT/COUNTER/clk
add wave -noupdate -group COUNTER /led_breathing_tb/DUT/COUNTER/rst
add wave -noupdate -group COUNTER /led_breathing_tb/DUT/COUNTER/count_enable
add wave -noupdate -group COUNTER -radix unsigned /led_breathing_tb/DUT/COUNTER/counter
add wave -noupdate -group COUNTER -radix unsigned /led_breathing_tb/DUT/COUNTER/counter_i
add wave -noupdate -group COUNTER /led_breathing_tb/DUT/COUNTER/clk
add wave -noupdate -group COUNTER /led_breathing_tb/DUT/COUNTER/rst
add wave -noupdate -group COUNTER /led_breathing_tb/DUT/COUNTER/count_enable
add wave -noupdate -group COUNTER -radix unsigned /led_breathing_tb/DUT/COUNTER/counter
add wave -noupdate -group COUNTER -radix unsigned /led_breathing_tb/DUT/COUNTER/counter_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {483890000000 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 210
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 fs} {1050 us}
