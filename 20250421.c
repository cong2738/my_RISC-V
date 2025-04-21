#include <stdint.h>

#define __IO volatile

typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t ODR;
} GPO_TypeDef;

typedef struct {
    __IO uint32_t MODER;
    __IO uint32_t IDR;
} GPI_TypeDef;

#define APB_BASEADDR    0x10000000
#define GPOA_BASEADDR   (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR   (APB_BASEADDR + 0x2000) 

#define GPOA            ((GPO_TypeDef *) GPOA_BASEADDR)
#define GPIB            ((GPI_TypeDef *) GPIB_BASEADDR)

// #define GPOA_MODER      *(uint32_t *)(GPOA_BASEADDR + 0x00)   
// #define GPOA_ODR        *(uint32_t *)(GPOA_BASEADDR + 0x04)
// #define GPIB_MODER      *(uint32_t *)(GPIB_BASEADDR + 0x00)   
// #define GPIB_IDR        *(uint32_t *)(GPIB_BASEADDR + 0x04)  

void delay(int n);

int main() {
    GPOA -> MODER = 0xff; // output mode
    GPIB -> MODER = 0x00; // input mode
    
    while(1) {
        GPOA -> ODR = GPIB -> IDR;
    }
    return 0;
}

void delay(int n) {
    uint32_t temp = 0;
    for (int i=0; i<n; i++){
        for (int j=0; j<1000; j++){
            temp++;
        }
    }
}