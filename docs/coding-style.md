# RTL Coding Style Conventions

## General
- **Language**: SystemVerilog (IEEE 1800-2017), with a focus on synthesizable constructs
- **File naming**: lowercase with underscores, module name matches file name (e.g., `alu.sv` for module `alu`)
- **Module naming**: lowercase with underscores, descriptive (e.g., `reg_file`, `control_unit`)
- **Indentation**: 4 spaces, no tabs
- **Line length**: 100 characters max

## Reset & Clock
- **Reset polarity**: Active-high reset (`rst`)
- **Reset type**: Synchronous reset
- **Clock signal**: Named `clk` throughout
- **Clock edge**: Always `posedge clk`

## Signal Naming
- **Active-low signals**: Suffixed with `_n` (e.g., `rst_n`, `stall_n`)
- **Registered outputs**: Suffixed with `_r` or `_reg` for local registers
- **Next-state signals**: Suffixed with `_next`
- **Constants**: UPPERCASE_WITH_UNDERSCORES
- **Parameters**: UPPERCASE_WITH_UNDERSCORES (e.g., `DATA_WIDTH`, `ADDR_WIDTH`)
- **Port directions**: Explicit (not `inout` unless tri-state is needed)
- **Bus signals**: `signal_name[MSB:LSB]` (e.g., `alu_result[31:0]`)

## Module Structure
```systemverilog
module module_name #(
    parameter WIDTH = 32
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] data_in,
    output logic [31:0] data_out
);
    // localparams
    // internal signals
    // combinational logic (always_comb)
    // sequential logic (always_ff)
    // submodule instantiations
endmodule
```

## Combinational Logic
- Use `always_comb` (not `always @(*)`)
- Use `assign` for simple continuous assignments
- Default all outputs at the top of `always_comb` blocks

## Sequential Logic
- Use `always_ff @(posedge clk or negedge rst_n)` for reset-enabled registers
- Use `always_ff @(posedge clk)` for non-reset registers

## FSM Style
- 2-process style (combinational next-state + sequential state register)
- State encoding: use `typedef enum` for readability
- Default case in state machine

## Testing
- Testbenches in `/tb/` directory
- Self-checking testbenches preferred; use `$error()` for failures
- Waveform dump via `$dumpfile` / `$dumpvars`
- Testbench file naming: `tb_<module_name>.sv`