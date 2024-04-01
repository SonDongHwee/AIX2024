onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib dpram_13x256_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {dpram_13x256.udo}

run 1000ns

quit -force
