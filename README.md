# Venus-DMA
### This is a DMA for Venus: A Wireless Multi-core Processing Unit for 5G baseband

Run `./run_sim.sh` to invoke Synopsys VCS simulation.

This DMA supports scatter-gather transfers. The CPU can write the desired transfer address, length, and other information into the DMA's registers, which will then be buffered in the hardware FIFO as DMA transfer requests. Physically, the DMA has only one transfer channel with a data path width of 512 bits. It supports unaligned transfers, with a minimum unaligned granularity of 8 bits.
![image text](https://github.com/Qpicpicxxz/Venus-DMA/tree/main/data/dma.png "DBSCAN Performance Comparison")
