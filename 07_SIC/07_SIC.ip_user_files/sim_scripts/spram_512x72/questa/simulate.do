onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib spram_512x72_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {spram_512x72.udo}

run 1000ns

quit -force
