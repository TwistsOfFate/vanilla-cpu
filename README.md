# Vanilla CPU

## Intro
Classic single-issue five-stage pipelined MIPS CPU with TLB support.
The master branch was used as submission to [NSCSCC](http://www.nscscc.org) 2020, a national competition on computer systems and architecture.

## Details
Implements 80 MIPS instructions and all required CP0 registers in MIPSr1 (however some of the implementations are adjusted to suit the needs of the competition).
Please refer to FDU1.2.pdf and FDU1.2.pptx for more details.

## Dual-issue branch
The dual-issue branch consists of a simple dual-issue five-stage CPU without TLB support. It comes with a higher IPC but lower frequency (~70 MHz).

## Contributors
- [Fanqi Yu](https://github.com/TwistsOfFate)
- [Weichen Li](https://github.com/kleinercubs)
- [Xiaoyu Han](https://github.com/HatsuneHan)
- [Yijun Ma](https://github.com/jasha64)
