onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib spram_256x64_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {spram_256x64.udo}

run 1000ns

quit -force
