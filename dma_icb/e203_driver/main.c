#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"
#include "dma.h"

# define NUM 128

int main(void)
{

    printf("\r\n###########Begin Test!!!###########\r\n");

    int32_t a[NUM] ={0}, b[NUM] = {0}, c[NUM*8] = {0}, d[NUM*8] = {0};
    
    int32_t test;

    for (int i = 0; i < NUM; i++){
        a[i] = i + 1;
    }

    for (int i = 0; i < NUM*8; i++){
        c[i] = i;
    }

    printf("\r\nAddress of a[] is %#x\r\n", a);
    printf("\r\nAddress of b[] is %#x\r\n", b);
    printf("\r\nAddress of c[] is %#x\r\n", c);
    printf("\r\nAddress of d[] is %#x\r\n", d);

    PLIC_Register_IRQ(PLIC_DMA_IRQn, 1, dma_irq_base_handler);  
    __enable_irq();

    dma_init(DMA_CFG);
    dma_config(DMA_CFG, a, b, NUM);
    dma_start(DMA_CFG);
    dma_wait(DMA_CFG);

    for (int i = 0; i < NUM; i++){
        printf("%d, \r\n", b[i]);
    }

    dma_config(DMA_CFG, c, d, NUM*8);
    dma_start(DMA_CFG);
    dma_wait(DMA_CFG);

    for (int i = 0; i < NUM; i++){
        printf("%d,  \r\n", d[i]);
    }

    for (int i = NUM*7; i < NUM*8; i++){
        printf("%d,  \r\n", d[i]);
    }

    // dma_disbale(DMA_CFG);

    printf("\r\n###########Finish!!!###########\r\n");

    return 0;

}
