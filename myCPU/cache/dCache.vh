`ifndef DCACHE_VH
`define DCACHE_VH

`timescale 1ns / 1ps

`define ADDR_WIDTH 32

// tag bits
`define CACHE_T 23
// set index bits
`define CACHE_S 4
// block offset bits
`define CACHE_B 5
// The sum of above bits should be 32 (ADDR_WIDTH)

// number of lines per set
`define CACHE_E 32

`define SET_NUM 2**`CACHE_S
`define BLOCK_SIZE 2**`CACHE_B

`endif
