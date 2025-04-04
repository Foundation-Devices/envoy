#import "GeneratedPluginRegistrant.h"

struct CharArray {
  uint32_t len;
  const char *string;
};

int32_t add(int32_t a, int32_t b);
char *ur_encoder(const char *message, uintptr_t message_len, uintptr_t max_fragment_len);
const char *ur_encoder_next_part(char *encoder);
const struct CharArray *ur_decoder_receive(char *decoder, const char *value);