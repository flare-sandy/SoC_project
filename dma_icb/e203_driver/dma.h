// See LICENSE for license details.
#ifndef _HBIRDV2_DMA_CFG_H
#define _HBIRDV2_DMA_CFG_H

#ifdef __cplusplus
 extern "C" {
#endif

int32_t dma_irq_base_handler(DMA_CFG_TypeDef *cfg);

int32_t dma_init(DMA_CFG_TypeDef *cfg);

int32_t dma_disbale(DMA_CFG_TypeDef *cfg);

int32_t dma_config(DMA_CFG_TypeDef *cfg, int32_t src_addr, int32_t dst_addr, int32_t length);

int32_t dma_start(DMA_CFG_TypeDef *cfg);

int32_t dma_wait(DMA_CFG_TypeDef *cfg);

#ifdef __cplusplus
}
#endif
#endif /* _HBIRDV2_DMA_CFG_H */