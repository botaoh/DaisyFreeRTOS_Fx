#include "DelayReverb.hpp"

void DelayReverbFX::Init(float samplerate) {
    chorus_.Init(samplerate);
    chorus_.SetLfoFreq(0.3f);
    chorus_.SetLfoDepth(0.5f); // Corrected function name!
}

float DelayReverbFX::Process(float input) {
    return chorus_.Process(input);
}
