TARGET = mineekrestore2
CC = xcrun -sdk macosx clang
CFLAGS = -fmodules -Wno-error
LDFLAGS = -framework Foundation ./MobileDevice.tbd

SRCS = main2.m
OBJS = $(SRCS:.m=.o)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.m
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
