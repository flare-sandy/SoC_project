#include "hbirdv2.h"
#include "dma.h"
#include <stdio.h>

int32_t dma_irq_base_handler(DMA_CFG_TypeDef *cfg){
    if (__RARELY(cfg == NULL)) {
        return -1;
    }
    printf("\r\nDMA TRANSFER DONE!\r\n");
    DMA_CFG -> CR = 0x00000001;
    printf("\r\nDMA IRQ CLEAR!\r\n");
    return 0;
}

int32_t dma_init(DMA_CFG_TypeDef *cfg){
    if (__RARELY(cfg == NULL)) {
        return -1;
    }
    printf("\r\nDMA INIT!\r\n");
    DMA_CFG -> CTR = 0x000000c0;
    return 0;
}

int32_t dma_disbale(DMA_CFG_TypeDef *cfg){
    if (__RARELY(cfg == NULL)) {
        return -1;
    }
    printf("\r\nDMA DISABLE!\r\n");
    DMA_CFG -> CTR = 0x00000000;
    return 0;
}

int32_t dma_config(DMA_CFG_TypeDef *cfg, int32_t src_addr, int32_t dst_addr, int32_t length){
    if (__RARELY(cfg == NULL)) {
        return -1;
    }

    DMA_CFG -> SRC_REG = src_addr;
    DMA_CFG -> DST_REG = dst_addr;
    DMA_CFG -> LEN_REG = length;
    printf("\r\nDMA CONFIG, SRC FROM %x, DST TO %x, LENGTH IS %d\r\n", src_addr, dst_addr, length);

    return 0;
}

int32_t dma_start(DMA_CFG_TypeDef *cfg){
    if (__RARELY(cfg == NULL)) {
        return -1;
    }
    printf("\r\nDMA START TRANSFER!\r\n");
    DMA_CFG -> CR = 0x00000080;
    return 0;
}

int32_t dma_wait(DMA_CFG_TypeDef *cfg){
    if (__RARELY(cfg == NULL)) {
        return -1;
    }
    while ((DMA_CFG -> SR & 0x00000002) == 0x00000000){
    }

    return 0;
}