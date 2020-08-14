`ifndef DCACHE_VH
`define DCACHE_VH

`timescale 1ns / 1ps

`define ADDR_WIDTH 32

// tag bits
`define DCACHE_T 20
// set index bits
`define DCACHE_S 7
// block offset bits
`define DCACHE_B 5
// The sum of above bits should be 32 (ADDR_WIDTH)

// number of lines per set
`define DCACHE_E 4
`define DCACHE_LINE_WIDTH 2

`define DSET_NUM 2**`DCACHE_S
`define DBLOCK_SIZE 2**`DCACHE_B

`endif
