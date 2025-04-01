#include "daisy_seed.h"
#include "daisysp.h"
#include "DelayReverb.hpp"
#include "FreeRTOS.h"
#include "task.h"

using namespace daisy;
using namespace daisysp;

// Global hardware and effect objects
DaisySeed hw;
DelayReverbFX fx;

// Audio callback for processing input -> output
void AudioCallback(AudioHandle::InputBuffer in, AudioHandle::OutputBuffer out, size_t size)
{
    for (size_t i = 0; i < size; i++)
    {
        float dry = in[0][i];
        float wet = fx.Process(dry);
        out[0][i] = out[1][i] = wet;
    }
}

// FreeRTOS task to start audio
void AudioTask(void* pvParameters)
{
    // Initialize FX
    fx.Init(hw.AudioSampleRate());

    // Start audio with callback
    hw.StartAudio(AudioCallback);

    // Main task loop does nothing – audio runs in interrupt
    while (1)
    {
        vTaskDelay(pdMS_TO_TICKS(1000)); // Optional: Sleep 1s per loop
    }
}

int main(void)
{
    // Init hardware (clocks, peripherals, etc.)
    hw.Configure();
    hw.Init();

    // Create the FreeRTOS task
    xTaskCreate(AudioTask,        // Task function
                "Audio",          // Name
                512,              // Stack size (words, not bytes)
                nullptr,          // Parameters
                tskIDLE_PRIORITY + 1, // Priority
                nullptr);         // Task handle

    // Start FreeRTOS scheduler
    vTaskStartScheduler();

    // Should never reach here
    while (1) {}
}
