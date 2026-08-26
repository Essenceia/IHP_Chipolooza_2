CELL_NAME=sg13cmos5l_ocd_Split2000
MAG_FILE=mag/${CELL_NAME}.mag
GDS_FILE=gds/${CELL_NAME}.gds
LEF_FILE=lef/${CALL_NAME}.lef

all: ${GDS_FILE} ${LEF_FILE}
.PHONEY: all

# start magic 
# magic -dnull -noconsole -rcfile ${PDK_ROOT}/${PDK}/libs.tech/magic/${PDK}.magicrc

${GDS_FILE}: ${MAG_FILE} 

${LEF_FILE}: ${MAG_FILE} 

clean: 
	rm -f ./${GDS_FILE}
	rm -f ./${LEF_FILE}
	

