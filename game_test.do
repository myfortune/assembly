# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all verilog modules in mux.v to working dir;
# could also have multiple verilog files.
vlog game_test.v

# Load simulation using mux as the top level simulation module.
vsim game_test

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}
add wave -divider control_top
add wave {/c_top/*}
add wave -divider datapath_top
add wave {/d_top/*}
add wave -divider user_beam
add wave {/a10/*}
add wave -divider control_beam
add wave {/a10/c10/*}

# First test case
#RESET
# Set input values using the force command, signal names need to be in {} brackets.
force {CLOCK_50} 1
force {KEY} 0000
force {go} 0

# Run simulation for a few ns.
run 10ns

# First test case
#RESET
# Set input values using the force command, signal names need to be in {} brackets.
force {CLOCK_50} 0
force {KEY} 0001
force {go} 1

# Run simulation for a few ns.
run 10ns

# First test case
#RESET
# Set input values using the force command, signal names need to be in {} brackets.
force {CLOCK_50} 1
force {KEY} 0001
force {go} 1

# Run simulation for a few ns.
run 10ns

# First test case
#RESET
# Set input values using the force command, signal names need to be in {} brackets.
force {CLOCK_50} 0 0, 1 20 -repeat 40
force {KEY} 0101
force {go} 0

# Run simulation for a few ns.
run 300ns

force {CLOCK_50} 0 0, 1 20 -repeat 40
force {KEY} 1001
force {go} 0

# Run simulation for a few ns.
run 300ns
