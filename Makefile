MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

RUN_TAG = $(shell ls librelane/runs/ | tail -n 1)
TOP = chip_top

PDK_ROOT ?= $(MAKEFILE_DIR)/IHP-Open-PDK
PDK ?= ihp-sg13g2
PDK_COMMIT ?= c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c

LIBRELANE_OPTS = --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk
LIBRELANE_CONFIGS = librelane/config.yaml

.DEFAULT_GOAL := help

SRC_DIR := src

$(PDK_ROOT)/$(PDK):
	ciel enable $(PDK_COMMIT) --pdk-root $(PDK_ROOT) --pdk-family $(PDK)

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
.PHONY: help

clone-pdk: $(PDK_ROOT)/$(PDK) ## Clone the IHP-Open-PDK repository
.PHONY: clone-pdk

all: librelane ## Build the project (runs LibreLane)
.PHONY: all

librelane: clone-pdk ## Run LibreLane flow (synthesis, PnR, verification)
	librelane ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS}
.PHONY: librelane

librelane-nodrc: clone-pdk ## Run LibreLane flow without DRC checks
	librelane ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS} --skip KLayout.DRC --skip Magic.DRC
.PHONY: librelane-nodrc

librelane-openroad: clone-pdk ## Open the last run in OpenROAD
	librelane ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS} --last-run --flow OpenInOpenROAD
.PHONY: librelane-openroad

librelane-klayout: clone-pdk ## Open the last run in KLayout
	librelane ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS} --last-run --flow OpenInKLayout
.PHONY: librelane-klayout

librelane-padring: clone-pdk ## Only create the padring
	python3 scripts/padring.py ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS}
.PHONY: librelane-padring

sim: ## Run RTL simulation with cocotb
	cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 chip_top_tb.py
.PHONY: sim

sim-gl: clone-pdk ## Run gate-level simulation with cocotb
	cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 chip_top_tb.py
.PHONY: sim-gl

sim-view: ## View simulation waveforms in GTKWave
	gtkwave cocotb/sim_build/chip_top.fst
.PHONY: sim-view

copy-final: ## Copy final output files from the last run
	rm -rf final/
	cp -r librelane/runs/${RUN_TAG}/final/ final/
.PHONY: copy-final

TOP_NAME := chip_core
entry_deps := $(wildcard ${SRC_DIR}/*.v) ${SRC_DIR}/${TOP_NAME}.sv
CONF := conf
WAIVER_FILE := waiver.vlt
LINT_FLAGS := -Wall -Wpedantic 

lint: $(entry_deps) ## Run lint on pure rtl blocks
	verilator $(CONF)/$(WAIVER_FILE) -y $(SRC_DIR) -DVERILATOR_LINT=1 --lint-only $(LINT_FLAGS) --no-timing $^ --top $(TOP_NAME)
.PHONY: lint
