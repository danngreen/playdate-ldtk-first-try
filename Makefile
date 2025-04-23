RUN_SIMULATOR := /usr/bin/open -a "/Users/dann/Developer/PlaydateSDK/bin/Playdate Simulator.app"
NAME := first
DEST_DIR = builds.pdx
DEST := builds.pdx/$(NAME).pdx
SOURCE := source


all: build run

$(DEST_DIR):
	mkdir -p $(DEST_DIR)

build: $(DEST_DIR)
	pdc $(SOURCE) $(DEST)

run:
	$(RUN_SIMULATOR) $(DEST)

.PHONY: run build
