#include <stdint.h>

#define __IO             volatile

typedef struct{
    __IO uint32_t MODER;
    __IO uint32_t ODR;
} GPO_TypeDef;

typedef struct{
    __IO uint32_t MODER;
    __IO uint32_t IDR;
} GPI_TypeDef;

typedef struct{
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
} GPIO_TypeDef;

typedef struct{
    __IO uint32_t FCR;
    __IO uint32_t FDR;
    __IO uint32_t DPR;
} FND_TypeDef;

#define APB_BASEADDR    0x10000000
#define GPOA_BASEADDR   (APB_BASEADDR + 0x1000)
#define GPIB_BASEADDR   (APB_BASEADDR + 0x2000)
#define GPIOC_BASEADDR  (APB_BASEADDR + 0x3000)
#define GPIOD_BASEADDR  (APB_BASEADDR + 0x4000)
#define FND_BASEADDR    (APB_BASEADDR + 0x5000)


#define GPOA            ((GPO_TypeDef *) GPOA_BASEADDR)
#define GPIB            ((GPI_TypeDef *) GPIB_BASEADDR)
#define GPIOC           ((GPIO_TypeDef *) GPIOC_BASEADDR)
#define GPIOD           ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define FND             ((FND_TypeDef *) FND_BASEADDR)

#define FND_OFF         0
#define FND_ON          1


void delay(int n);

void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);

void Switch_init(GPIO_TypeDef *GPIOx);
uint32_t Switch_read(GPIO_TypeDef *GPIOx);

void FND_init(FND_TypeDef *fnd, uint32_t ON_OFF);
void FND_writeData(FND_TypeDef *fnd, uint32_t data);
void FND_writeDP(FND_TypeDef *fnd, uint32_t ON_OFF);


int main()
{
    FND_init(FND, FND_ON);

    int dp = 0b1111;
    uint32_t count = 0;
    uint32_t count_dot = 0;
    while(1)
    {
        if(count_dot == 10) {
            count_dot = 0;
            dp = 0b1111;
        } else if (count_dot == 5){
            dp = 0b1101;
        }
        if(count == 10000) count = 0;
        FND_writeData(FND, count);
        FND_writeDP(FND, dp);
        delay(100);

        count++;
        count_dot++;
    }
    return 0;
}

void delay(int n)
{
    uint32_t temp = 0;
    for (int i=0; i<n; i++){
        for (int j=0; j<1000; j++){
            temp++;
        }
    }
}

void LED_init(GPIO_TypeDef *GPIOx)
{
    GPIOx->MODER = 0xff;
}

void LED_write(GPIO_TypeDef *GPIOx, uint32_t data)
{
    GPIOx->ODR = data;
}

void Switch_init(GPIO_TypeDef *GPIOx)
{
    GPIOx->MODER = 0x00;
}

uint32_t Switch_read(GPIO_TypeDef *GPIOx)
{
    return GPIOx->IDR;
}

void FND_init(FND_TypeDef *fnd, uint32_t dp)
{
    fnd->FCR = dp;
}

void FND_writeDP(FND_TypeDef *fnd, uint32_t ON_OFF) {
    fnd->DPR = ON_OFF;

}

void FND_writeData(FND_TypeDef *fnd, uint32_t data)
{
    fnd->FDR = data;
}