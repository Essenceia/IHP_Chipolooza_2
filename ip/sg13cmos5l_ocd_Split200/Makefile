CELL_NAME=sg13cmos5l_ocd_Split200
MAG_FILE=mag/${CELL_NAME}.mag
GDS_FILE=gds/${CELL_NAME}.gds
LEF_FILE=lef/${CALL_NAME}.lef

all: ${MAG_FILE}
	magic -dnull -noconsole -rcfile ${PDK_ROOT}/${PDK}/libs.tech/magic/${PDK}.magicrc convert_mag.tcl
.PHONEY: all

magic: ${MAG_FILE} 
	magic -rcfile ${PDK_ROOT}/${PDK}/libs.tech/magic/${PDK}.magicrc ${MAG_FILE}
.PHONEY: magic 

clean: 
	rm -f ./gds/*
	rm -f ./lef/*
	

