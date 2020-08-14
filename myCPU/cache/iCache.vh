`ifndef ICACHE_VH
`define ICACHE_VH

`timescale 1ns / 1ps

`define ADDR_WIDTH 32

// tag bits
`define ICACHE_T 20
// set index bits
`define ICACHE_S 6
// block offset bits
`define ICACHE_B 6
// The sum of above bits should be 32 (ADDR_WIDTH)

// number of lines per set
`define ICACHE_E 4

`define ISET_NUM 2**`ICACHE_S
`define IBLOCK_SIZE 2**`ICACHE_B

`endif
