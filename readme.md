# FDU1.2 Cache Version

mycpu模块对外接口目前仍然保持类SRAM接口

mycpu_top下有两个模块 mycpu和cpu_axi_interface，期中cpu_axi_interface负责把类SRAM接口转换为AXI

mycpu下有三个模块 mypipeline，icache和dcache

mypipeline是稳定通过FPS三类测试后重新封装的流水线（重新封装后跑了一下功能仿真没有问题）



## Superscalar

在mycpu模块下目前dcache模块被屏蔽，icache和mypipeline的接口已经对上了（可以再检查一下），理论上只需要修改mypipeline内部代码就行了

接口修改如下：

inst_addr扩展为inst_addr_1和inst_addr_2（默认先读1）

inst_rdata扩展为inst_rdata_1和inst_rdata_2（默认先读1）

增加second_data_ok第二流水线指令信号

