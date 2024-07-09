# openmips
这是我的《自己动手写CPU》的学习记录，本书code可以从 https://github.com/Z-Y00/Examples-in-book-write-your-own-cpu 获取，感谢作者雷思磊的开源，本项目code可任意使用。

## 5.26 
安装Modelsim ，配置环境 ，画框架图，了解mips

## 5.27
完成初始openmips_min

## 5.28
完成openmips_min_spoc并完成仿真验证第一条指令ori的实现

完成第四章

## 5.29
添加i指令和中断一些指令，并通过仿真验证

完成第五章

## 5.30
添加mov指令，并完成仿真验证 

添加 movn movz mfhi mflo mthi mtlo指令

其中，在实现数据依赖时仿真mfhi和mflo时出现传递后要传入的寄存器清空为X，后经过验证查找发现是openmips调用时传错参数，还是要多看框架图

## 5.31
初步完成arth基本算术指令，其中 addi 出现问题，add &3, &3, 2时，寄存器3无变化，然后stimulate模拟全过程

观察id阶段指令aluop_i正确，立即数imm 2正确，ex 输出结果正确，mem阶段正确，wb写入正确，然后发现结果又对了。

（ps：可能是vscode和modelsim编程和仿真分离的原因。没有同步，导致使用之前未修改的版本导致的）

## 6.1 
完成arth，其中slti 和sltiu 使用的是 slt和sltu的标识码，因为没有明显区分，所以可以调用，这里需要注意

还有mul指令乘数，被乘数，结果 的正负判断需要注意

## 6.2
完成ctrl指令，设计MADD，MADDU，MSUB，MSUBU 指令。

## 6.3
实现MADD，MADDU，MSUB，MSUBU，其中stallreq出现错误，ex中的stallreq忘记赋值导致错误。同时仿真发现MADD，MADDU可行，但是MSUB，MSUBU不可行，modelsim报错LOOP，但是实际不会进入循环（因为没有循环），让人费解

## 6.4
解决问题，通过计算并未发现问题，通过和作者源代码比较，发现只有
```
end else if ((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
				whilo_o <= `WriteEnable;
				hi_o <=hilo_temp1[63:32];
				lo_o <=hilo_temp1[31:0];
				end else if ((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
				whilo_o <= `WriteEnable;
				hi_o <=hilo_temp1[63:32];
				lo_o <=hilo_temp1[31:0];
```
这段代码不同，我之前认为他们可以放在一起，因为他们功能一样，操作一样。现在看来可能是仿真模拟的时候是不一样的，导致错误。（奇怪，先搁置）
## 6.5
完成div.v试商法的设计，拓展testbench的时间。

## 6.6
实现div，divu指令，添加div，并仿真验证。

##期末考

## 7.2
实现转移指令j b，通过延迟槽实现，并仿真验证。

##7.5
load store 指令

#7.9
完成load store，并仿真验证
