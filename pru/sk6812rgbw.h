#ifndef SK6812RGBW_H
#define SK6812RGBW_H

#include <stdint.h>

typedef struct {
  uint8_t red;
  uint8_t green;
  uint8_t blue;
  uint8_t white;
} rgbw;

enum sk6812rgbw_cmd {
  SK6812RGBW_GO,
};

struct sk6812rgbw_control {
  enum sk6812rgbw_cmd command;
  size_t num_leds;
  const rgbw *leds_data;
};

#endif
