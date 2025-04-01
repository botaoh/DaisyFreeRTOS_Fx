#pragma once
#include "chorus.h"

using namespace daisysp;

class DelayReverbFX {
public:
    void Init(float samplerate);
    float Process(float input);

private:
    Chorus chorus_;
};
