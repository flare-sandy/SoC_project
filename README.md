# SoC_project
这是上海交通大学微纳电子系2023年春季课程《SoC设计方法》的Final Project.

## 2023/6/16 TODO
- [x] 耦合脉动阵列和SRAM，实现SRAM的高存储利用
- [x] 如何使用脉动阵列计算分块矩阵乘，需要考虑一下
- [ ] 为脉动阵列设计
- [x] matlab完成golden_model

<img src="https://github.com/flare-sandy/SoC_project/blob/main/doc/block_matmul.jpg" width="800px">


寄存器需要定义的信号：
两个输入矩阵的基地址（12位），输出矩阵的基地址（12位），估计用三个寄存器
控制信号：k_config,scaled_factor,trans_config,start,clear,
反馈信号：done
控制和反馈用一个寄存器
写数据的地址和长度，读数据的地址和长度

需要设计的矩阵乘维度：$32 \times 96, 96\times 96$, $32\times, 48, 48\times 32$, $32\times 32, 32\times 48$
拆分后的分块乘对应的$k$维度：32，48，96