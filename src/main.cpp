#include <cstdio>
#include "stm32746g_discovery.h"

#include "ff_gen_drv.h"
#include "sd_diskio.h"

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
FATFS SDFatFs;  /* File system object for SD card logical drive */
FIL MyFile;     /* File object */
char SDPath[4]; /* SD card logical drive path */
uint8_t workBuffer[_MAX_SS];

/* Private function prototypes -----------------------------------------------*/
static void SystemClock_Config(void);
static void Error_Handler(void);
static void CPU_CACHE_Enable(void);

int main(void)
{
   FRESULT res;                            /* FatFs function common result code */
   uint32_t bytesread;                     /* File write/read counts */
   uint8_t rtext[100];                     /* File read buffer */

   printf("Hello World!\n");

   BSP_LED_Init(LED1);

   /* Enable the CPU Cache */
   CPU_CACHE_Enable();

   /* STM32F7xx HAL library initialization:
        - Configure the Flash ART accelerator on ITCM interface
        - Configure the Systick to generate an interrupt each 1 msec
        - Set NVIC Group Priority to 4
        - Global MSP (MCU Support Package) initialization
      */
   HAL_Init();

   /* Configure the system clock to 216 MHz */
   SystemClock_Config();

   /*##-1- Link the micro SD disk I/O driver ##################################*/
   if(FATFS_LinkDriver(&SD_Driver, SDPath) == 0)
   {
     /*##-2- Register the file system object to the FatFs module ##############*/
     if(f_mount(&SDFatFs, (TCHAR const*)SDPath, 0) != FR_OK)
     {
       /* FatFs Initialization Error */
       Error_Handler();
     }
     else
     {
         /*##-4- Create and Open a new text file object with write access #####*/
         if(f_open(&MyFile, "arroz/cenoura.txt", FA_READ) != FR_OK)
         {
           /* 'STM32.TXT' file Open for read Error */
           Error_Handler();
         }
         else
         {
           /*##-5- Write data to the text file ################################*/
           res = f_read(&MyFile, rtext, sizeof(rtext), (UINT*)&bytesread);

           if((bytesread == 0) || (res != FR_OK))
           {
              /* 'STM32.TXT' file Read or EOF Error */
             Error_Handler();
           }
           else
           {
             /*##-6- Close the open text file #################################*/
             f_close(&MyFile);

             fwrite(rtext, sizeof(char), bytesread, stdout);
             fflush(stdout);
             /* Success of the demo: no error occurrence */
             BSP_LED_On(LED1);
           }
         }
     }
   }

   /*##-11- Unlink the micro SD disk I/O driver ###############################*/
   FATFS_UnLinkDriver(SDPath);

   return 0;
}

/**
  * @brief  System Clock Configuration
  *         The system Clock is configured as follow :
  *            System Clock source            = PLL (HSE)
  *            SYSCLK(Hz)                     = 216000000
  *            HCLK(Hz)                       = 216000000
  *            AHB Prescaler                  = 1
  *            APB1 Prescaler                 = 4
  *            APB2 Prescaler                 = 2
  *            HSE Frequency(Hz)              = 25000000
  *            PLL_M                          = 25
  *            PLL_N                          = 432
  *            PLL_P                          = 2
  *            PLL_Q                          = 9
  *            VDD(V)                         = 3.3
  *            Main regulator output voltage  = Scale1 mode
  *            Flash Latency(WS)              = 7
  * @param  None
  * @retval None
  */
static void SystemClock_Config(void)
{
  RCC_ClkInitTypeDef RCC_ClkInitStruct;
  RCC_OscInitTypeDef RCC_OscInitStruct;
  HAL_StatusTypeDef ret = HAL_OK;

  /* Enable HSE Oscillator and activate PLL with HSE as source */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 25;
  RCC_OscInitStruct.PLL.PLLN = 432;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 9;

  ret = HAL_RCC_OscConfig(&RCC_OscInitStruct);
  if(ret != HAL_OK)
  {
    while(1) { ; }
  }

  /* Activate the OverDrive to reach the 216 MHz Frequency */
  ret = HAL_PWREx_EnableOverDrive();
  if(ret != HAL_OK)
  {
    while(1) { ; }
  }

  /* Select PLL as system clock source and configure the HCLK, PCLK1 and PCLK2 clocks dividers */
  RCC_ClkInitStruct.ClockType = (RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2);
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  ret = HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_7);
  if(ret != HAL_OK)
  {
    while(1) { ; }
  }
}

/**
  * @brief  CPU L1-Cache enable.
  * @param  None
  * @retval None
  */
static void CPU_CACHE_Enable(void)
{
  /* Enable I-Cache */
  SCB_EnableICache();

  /* Enable D-Cache */
  SCB_EnableDCache();
}

/**
  * @brief  This function is executed in case of error occurrence.
  * @param  None
  * @retval None
  */
static void Error_Handler(void)
{
  /* Turn LED1 on */
  BSP_LED_On(LED1);
  while(1)
  {
    BSP_LED_Toggle(LED1);
    HAL_Delay(200);
  }
}

/**
  * @brief  This function handles SysTick Handler.
  * @param  None
  * @retval None
  */
extern "C" void SysTick_Handler(void)
{
  HAL_IncTick();
}
