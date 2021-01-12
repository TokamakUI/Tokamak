LINKER_FLAGS := $(shell pkg-config --libs gtk+-3.0 gdk-3.0)
C_FLAGS := $(shell pkg-config --cflags gtk+-3.0)
SWIFT_LINKER_FLAGS ?= -Xlinker $(shell echo $(LINKER_FLAGS) | sed -e "s/ / -Xlinker /g" | sed -e "s/-Xlinker -Wl,-framework,/-Xlinker -framework -Xlinker /g")
SWIFT_C_FLAGS ?= -Xcc $(shell echo $(C_FLAGS) | sed -e "s/ / -Xcc /g")

all: build

build:
	swift build --enable-test-discovery --product TokamakGTKDemo $(SWIFT_C_FLAGS) $(SWIFT_LINKER_FLAGS)

run: build
	.build/debug/TokamakGTKDemo
