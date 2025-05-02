SUBDIRS := hello_world

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

clean: $(SUBDIRS)

.PHONY: all $(SUBDIRS) clean