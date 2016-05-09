# btrace448
Hardware ray tracer for Xilinx Artix-7 FPGA.

## Purpose of project

Create a simple ray tracer in hardware. Ray tracing is used to render 3-dimensional environments.

## Current state of project

The initial goal is to display spheres on a VGA display with simple point-light-surface-normal shading. This goal is being used to orient the development of this project.

- [x] Square-root LUT unit (Fixed-point representation)
  - [x] Test bench
  - ~~[ ] Linear interpolation~~
  - [ ] Generator scripts
- [x] Ray generator unit
  - [x] Test bench
  - [x] Adjustable camera position
  - ~~[ ] Adjustable camera rotation~~
- [x] General purpose arithmetic
- [x] Object record table
- [x] Object-ray collision unit
- [x] VGA display controller
  - [x] Frame buffer (BRAM)
  - ~~[ ] Read/write multi-access arbiter~~
    - Using dual-port BRAM
- [x] 'btrace' package
- [x] Controller

Status: The project, in this current revision, is unable to be implemented in hardware due to timing constraints (Requires 100MHz clock frequency, ~33MHz attainable).

## Project hierarchy

- **btrace** - Ray tracing devices
- **core** - Anything VGA and I/O
- **math** - Arithmetic devices
- **scripts** - Any scripts used to assist in the development of this project
- **results** - Results from simulation

## References

- [Ray Tracing](https://en.wikipedia.org/wiki/Ray_tracing_(graphics)) - Wikipedia
- [FPGA Prototyping by VHDL Examples](http://academic.csuohio.edu/chu_p/rtl/fpga_vhdl.html) - Companion website to book
