# hyp-test: Non-parametric hypothesis testing.
# Copyright (C) 2006-2012  Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
