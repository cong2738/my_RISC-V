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

typedef struct{
    __IO uint32_t FCR;
    __IO uint32_t FDR;
    __IO uint32_t DPR;
} FIFO_TypeDef;

typedef struct{
    __IO uint32_t FCR;
    __IO uint32_t TCNT;
    __IO uint32_t PSC;
    __IO uint32_t ARR;
} COUNTER_TypeDef;


#define APB_BASEADDR        0x10000000
#define GPIOA_BASEADDR       (APB_BASEADDR + 0x1000)
#define GPIOB_BASEADDR       (APB_BASEADDR + 0x2000)
#define GPIOC_BASEADDR      (APB_BASEADDR + 0x3000)
#define GPIOD_BASEADDR      (APB_BASEADDR + 0x4000)
#define FND_BASEADDR        (APB_BASEADDR + 0x5000)
#define FIFO_BASEADDR       (APB_BASEADDR + 0x6000)
#define COUNTER_BASEADDR    (APB_BASEADDR + 0x7000)


#define GPIOA            ((GPIO_TypeDef *) GPIOA_BASEADDR)
#define GPIOB            ((GPIO_TypeDef *) GPIOB_BASEADDR)
#define GPIOC           ((GPIO_TypeDef *) GPIOC_BASEADDR)
#define GPIOD           ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define FND             ((FND_TypeDef *) FND_BASEADDR)
#define FIFO            ((FIFO_TypeDef *) FIFO_BASEADDR)
#define COUNTER         ((COUNTER_TypeDef *) COUNTER_BASEADDR)

#define FND_OFF         0
#define FND_ON          1
#define button_1        4
#define button_2        5
#define button_3        6
#define button_4        7

void delay(int n);

void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);

void Switch_init(GPIO_TypeDef *GPIOx);
uint32_t Switch_read(GPIO_TypeDef *GPIOx);

void FND_init(FND_TypeDef *fnd, uint32_t ON_OFF);
void FND_writeData(FND_TypeDef *fnd, uint32_t data);
void FND_writeDP(FND_TypeDef *fnd, uint32_t ON_OFF);

void counter_init(COUNTER_TypeDef* cnt,uint32_t psc,uint32_t arr);
void counter_start(COUNTER_TypeDef* cnt);
void counter_stop(COUNTER_TypeDef* cnt);
void counter_wtitePrescaler(COUNTER_TypeDef* cnt,uint32_t psc);
void counter_wtiteAutoReload(COUNTER_TypeDef* cnt,uint32_t arr);
void counter_clear(COUNTER_TypeDef* cnt);
uint32_t counter_read(COUNTER_TypeDef* cnt);

void func1( uint32_t *prevTime, uint32_t *func_data){
    uint32_t curvTime = counter_read(COUNTER);
    if(curvTime - *prevTime < 200) return;
    *prevTime = curvTime;

    *func_data ^= 1<<1;
    LED_write(GPIOC,*func_data);
}
void func2( uint32_t *prevTime, uint32_t *func_data){
    uint32_t curvTime = counter_read(COUNTER);
    if(curvTime - *prevTime < 500) return;
    *prevTime = curvTime;

    *func_data ^= 1<<2;
    LED_write(GPIOC,*func_data);
}
void func3( uint32_t *prevTime, uint32_t *func_data){
    uint32_t curvTime = counter_read(COUNTER);
    if(curvTime - *prevTime < 1000) return;
    *prevTime = curvTime;

    *func_data ^= 1<<3;
    LED_write(GPIOC,*func_data);
}
void func4( uint32_t *prevTime, uint32_t *func_data){
    uint32_t curvTime = counter_read(COUNTER);
    if(curvTime - *prevTime < 1500) return;
    *prevTime = curvTime;

    *func_data ^= 1<<4;
    LED_write(GPIOC,*func_data);
}
void power( uint32_t* prevTime, uint32_t* power_data){
    uint32_t curvTime = counter_read(COUNTER);
    if(curvTime - *prevTime < 500) return;
    *prevTime = curvTime;

    *power_data ^= 1<<0;
    LED_write(GPIOC,power_data);
}

enum{FUNC1,FUNC2,FUNC3,FUNC4};

int main()
{
    uint32_t func1prevTime = 0;
    uint32_t func2prevTime = 0;
    uint32_t func3prevTime = 0;
    uint32_t func4prevTime = 0;
    uint32_t func1_data = 0b0000;
    uint32_t func2_data = 0b0000;
    uint32_t func3_data = 0b0000;
    uint32_t func4_data = 0b0000;
    uint32_t prevTime = 0;
    uint32_t power_data = 0b0000;

    LED_init(GPIOC);
    Switch_init(GPIOD);
    counter_init(COUNTER,100000-1,0xffffffff);
    counter_start(COUNTER);
    
    uint32_t state = FUNC1;

    while(1)
    {
        power(&prevTime,
            &power_data);
        switch (state)
        {
        case FUNC1:
            func1(&func1prevTime,
                &func1_data);
            break;
        case FUNC2:
            func2(&func2prevTime,
                &func2_data);
            break;
        case FUNC3:
            func3(&func3prevTime,
                &func3_data);
            break;
        case FUNC4:
            func4(&func4prevTime,
                &func4_data);
            break;
        }

        switch (state)
        {
        case FUNC1:
            if(Switch_read(GPIOD) & (1<<button_2)) {
                state = FUNC2;
            } else if(Switch_read(GPIOD) & (1<<button_3)) {
                state = FUNC3;
            } else if(Switch_read(GPIOD) & (1<<button_4)) {
                state = FUNC4;
            } else state  = FUNC1;
            break;
        case FUNC2:
            if(Switch_read(GPIOD) & (1<<button_1)) {
                state = FUNC1;
            } else if(Switch_read(GPIOD) & (1<<button_3)) {
                state = FUNC3;
            } else if(Switch_read(GPIOD) & (1<<button_4)) {
                state = FUNC4;
            } else state  = FUNC2;
            break;
            break;
        case FUNC3:
            if(Switch_read(GPIOD) & (1<<button_1)) {
                state = FUNC1;
            } else if(Switch_read(GPIOD) & (1<<button_2)) {
                state = FUNC2;
            } else if(Switch_read(GPIOD) & (1<<button_4)) {
                state = FUNC4;
            } else state  = FUNC3;
            break;
            break;
        case FUNC4:
            if(Switch_read(GPIOD) & (1<<button_1)) {
                state = FUNC1;
            } else if(Switch_read(GPIOD) & (1<<button_2)) {
                state = FUNC2;
            } else if(Switch_read(GPIOD) & (1<<button_3)) {
                state = FUNC3;
            } else state  = FUNC4;
            break;
            break;
        }
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

void counter_init(COUNTER_TypeDef* cnt,uint32_t psc,uint32_t arr){
    cnt->FCR = 0b00;
    counter_wtitePrescaler(cnt,psc);
    counter_wtiteAutoReload(cnt,arr);
} 

void counter_start(COUNTER_TypeDef* cnt){
    cnt->FCR |= (1<<0);
}

void counter_stop(COUNTER_TypeDef* cnt){
    cnt->FCR |= ~(1<<0);
}

void counter_wtitePrescaler(COUNTER_TypeDef* cnt,uint32_t psc){
    cnt->PSC = psc;
}
void counter_wtiteAutoReload(COUNTER_TypeDef* cnt,uint32_t arr){
    cnt->ARR = arr;
}


void counter_clear(COUNTER_TypeDef* cnt){
    cnt->FCR |= (1<<1);
    cnt->FCR &= ~(1<<1);
} 

uint32_t counter_read(COUNTER_TypeDef* cnt) {
    return cnt->TCNT;
}