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
