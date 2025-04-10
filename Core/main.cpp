#include "daisy_seed.h"
#include "FreeRTOS.h"
#include "task.h"
#include "FreeRTOSConfig.h"  // Ensure this is in your include path

using namespace daisy;
DaisySeed hw; // Check namespace; if defined as daisy::seed::DaisySeed, adjust accordingly

extern uint32_t SystemCoreClock; // Provided by system_stm32h7xx.c

// Simple LED blink task
void BlinkTask(void* pvParameters) {
    bool led_state = false;
    while(1) {
        led_state = !led_state;
        hw.SetLed(led_state);
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}


int main(void)
{
    hw.Configure();
    hw.Init();

    // Configure SysTick using the system clock and tick rate from FreeRTOSConfig.h
    if (SysTick_Config(SystemCoreClock / configTICK_RATE_HZ)) {
        while (1) {} // SysTick configuration error: halt
    }

    BaseType_t ret = xTaskCreate(BlinkTask, "Blink", 256, nullptr, tskIDLE_PRIORITY, nullptr);
    if (ret != pdPASS) {
        while (1) {} // Task creation failed
    }

    vTaskStartScheduler();

    // If scheduler returns, something went wrong.
    while (1) {}
}
