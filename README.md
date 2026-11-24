# Configurable Multi-Channel PWM Generator — Artix-7 / Vivado

A synthesizable Verilog-2001 PWM generator for Xilinx Artix-7 FPGAs. The design supports runtime-configurable PWM period and independent duty-cycle values for multiple output channels.

## Features

- Parameterized number of PWM channels (`NUM_CHANNELS`)
- Parameterized counter width (`COUNTER_WIDTH`)
- Runtime-configurable PWM period in clock cycles
- Independent runtime-configurable duty time for every channel
- Synchronous active-low reset
- Global enable input
- Self-checking simulation testbench
- Vivado Tcl project creation script
- Board-constraint template for adding verified pin assignments

## Repository layout

```text
configurable_pwm_artix7/
├── README.md
├── .gitignore
├── rtl/
│   └── configurable_pwm_generator.v
├── sim/
│   └── tb_configurable_pwm_generator.v
├── constraints/
│   └── artix7_template.xdc
└── scripts/
    └── create_vivado_project.tcl
```

## Interface

| Signal | Direction | Description |
|---|---|---|
| `clk` | input | FPGA clock |
| `reset_n` | input | Synchronous active-low reset |
| `enable` | input | Enables PWM operation |
| `period_cycles` | input | PWM period, measured in clock cycles |
| `duty_cycles` | input | Packed duty values, one `COUNTER_WIDTH`-bit value per channel |
| `pwm_out` | output | One PWM output per channel |

`duty_cycles` is a packed bus. Channel 0 occupies bits `[COUNTER_WIDTH-1:0]`, channel 1 occupies the next `COUNTER_WIDTH` bits, and so on.

### Frequency and duty-cycle calculation

The PWM frequency is:

\[
f_{PWM} = \frac{f_{CLK}}{period\_cycles}
\]

For each channel:

\[
Duty(\%) = \frac{duty\_cycles[channel]}{period\_cycles} \times 100
\]

Example with a 100 MHz input clock:

- `period_cycles = 100000` gives 1 kHz PWM.
- `duty_cycles[channel] = 25000` gives 25% duty cycle.
- `duty_cycles[channel] = 50000` gives 50% duty cycle.
- `duty_cycles[channel] = 75000` gives 75% duty cycle.

Use integer cycle counts. For best results, keep `period_cycles` at 2 or greater. A value of 0 or 1 is treated as a one-clock period. A duty value greater than or equal to the period produces a continuously high output during enabled operation.

## Vivado setup

1. Extract this ZIP.
2. Open Vivado and open the Tcl Console.
3. Change directory to the extracted project folder.
4. Run:

   ```tcl
   source scripts/create_vivado_project.tcl
   ```

5. The script creates a project with a generic Artix-7 part (`xc7a35tcpg236-1`). **Edit `PART` in the Tcl script to match the exact FPGA part on your board before building.**
6. Run behavioral simulation with `tb_configurable_pwm_generator` as the simulation top.
7. For synthesis, use `configurable_pwm_generator` as the RTL top.

## Physical FPGA board notes

The XDC file is intentionally a template. Artix-7 boards have different FPGA packages and pinouts. Before programming hardware, copy the correct master XDC for your exact board, add verified pin assignments for the clock, reset, enable, period, duty inputs and PWM outputs, and set the correct I/O standards. Do not use placeholder pins.

For a practical board demo, you may create a separate wrapper module that maps switches/buttons to configuration inputs and maps `pwm_out` to board LEDs or PMOD pins. The reusable PWM core in `rtl/` is independent of any specific board.

## GitHub upload

```bash
git init
git add .
git commit -m "Add configurable multi-channel PWM generator"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
git push -u origin main
```

Replace the remote URL with your repository URL.
