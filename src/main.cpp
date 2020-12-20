#include <cstdio>
#include "stm32746g_discovery.h"

int main(void)
{
   printf("Hello World!\n");

   BSP_LED_Init(LED1);

   BSP_LED_On(LED1);

   return 0;
}
