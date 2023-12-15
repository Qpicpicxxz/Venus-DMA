#!/bin/bash
export PATH="$PATH:/home/software/synopsys/vcs-mx/O-2018.09-SP2-11/bin/"
export VCS_HOME="/home/software/synopsys/vcs-mx/O-2018.09-SP2-11/"


# vcs编译后生成二进制文件simv
rm -rf ./csrc *.daidir *.log simv* *.key *.vpd *.vcd *.saif *.fsdb novas* ./DVEfiles ./vfastLog ./work.lib++ ./AN.DB ./64
rm -rf ./recorder
mkdir ./recorder
echo "generating filelist..."

# compile
OUTPUT=dma_tb
# `+vpdfile+filename`可以更改生成vpd文件的文件名，默认为 vpdplus.vpd
VPD_NAME=+vpdfile+${OUTPUT}.vpd
# `+define+macro`使用源代码中`ifdef所定义的宏或者define源代码中的宏
DUMP_VCD=+define+DUMP_VCD
BEHAV_SIM=+define+ARM_UD_MODEL
# Verdi是Synopsys公司提供的一款交互式调试和波形查看工具，用于调试Verilog或VHDL代码
# VCS是Synopsys公司提供的Verilog编译器和仿真器，并生成仿真波形
VERDI_PATH="/home/software/synopsys/verdi/O-2018.09-SP2-11/share/PLI/VCS/linux64"
echo "compiling..."

# vlogan是Synopsys的Verilog编译器和分析工具
# `-full64`：支持64位模式下的编译仿真
# `-kdb`：生成verdi KDB数据库
# `-sverilog`：支持SystemVerilog
# `+v2k`：支持verilog2001的标准
# `-v2k_gengerte`：指示编译器生成verilog2001格式的文件
# `-f ./filelist.f`：从`filelist.f`里面读取文件列表
# `-l compile_vlog.log`：将编译日志写入`compile_vlog.log`文件
# `+incdir`：指定编译器搜索头文件目录的选项
# `-timescale = 1ns/1ps`：1ns为单位时间，1ps为最小时间单位
# `-assert svaext`：指示编译器开启SVA(System Verilog Assertions)扩展
vlogan  -full64 -kdb -sverilog +v2k -v2k_generate \
        -f ./filelist.f \
        -l compile_vlog.log  \
				+incdir+./rtl/inc \
        -timescale=1ns/1ps   \
				-assert svaext

# `vcs`：使用VCS编译器
# `test`：指定要编译的测试文件/顶层模块的名称
# `-lca`：启用逻辑仿真的抽象模式，可以提高仿真速度
# `+lint`：Verilog的linting的级别，拥有strict, medium, lenient等级别选项
# `-LDFLAGS`：告诉编译器这个是传递给链接器的选项
# `-Wl,--no-as-needed`：指示连接器在链接时不要丢弃掉那些被认为「不需要」的库
# `-debug_access+all`：开启对所有调试访问的支持
# `-o`：指定输出文件的名称
# `pli.a`：PLI（Programming Language Interface）库文件的路径
vcs   dma_tb  -full64	-kdb -lca	\
      +lint=TFIPC-L -LDFLAGS -Wl,--no-as-needed	\
      -timescale=1ns/1ps			\
      -debug_access+all 			\
      -o ${OUTPUT}					\
      -l compile.log				\
      ${VPD_NAME}					\
      -P ${VERDI_PATH}/novas.tab	\
      ${VERDI_PATH}/pli.a

# run simulation
echo "simulating..."
./${OUTPUT} ${VPD_NAME} -gui=dve &

# GUI
echo "invoking gui..."