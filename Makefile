SUBDIRS = BH-0.1 BHSets-0.1 Math-R-0.1 StatTests-0.1 XFig-0.1

# Main target
.PHONY: all
all:

# Clean
.PHONY: clean
clean:

# Distclean
.PHONY: distclean
distclean:

# Subdir target template
define WRAPPED_SUBDIR_TARGET_TEMPLATE
.PHONY: $(2)_$(1)
$(2)_$(1):
	$$(MAKE) -C $(1) -f Makefile.wrap $(2)

$(2): $(2)_$(1)

endef

# Call each one of them
$(foreach s, $(SUBDIRS), \
    $(foreach t, all clean distclean, \
	$(eval $(call WRAPPED_SUBDIR_TARGET_TEMPLATE,$(s),$(t)))))
