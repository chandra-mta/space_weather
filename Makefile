############################
# Change the task name!
############################
TASK = space_weather

include /data/mta4/MTA/include/Makefile.MTA

BIN  = G10_calc.csh G11_calc.csh G11_viol.pl G12_calc.csh G8_calc.csh ace_invalid_data.csh ace_invalid_spec.csh aceviolation.csh aceviolation_electrons.csh aceviolation_protons.csh aceviolation_protonsP3_P5.csh aceviolation_protonsP5.csh aceviolation_protonsP6.csh calculate.csh calculate_kp.csh kpalert.pl
DATA = image2 image_i acedata rob1 footer
WWW = ace.html
#DOC  = ReadMe

install:
ifdef BIN
	rsync --times --cvs-exclude $(BIN) $(INSTALL_BIN)/
endif
ifdef DATA
	mkdir -p $(INSTALL_DATA)
	rsync --times --cvs-exclude $(DATA) $(INSTALL_DATA)/
endif
ifdef DOC
	mkdir -p $(INSTALL_DOC)
	rsync --times --cvs-exclude $(DOC) $(INSTALL_DOC)/
endif
ifdef IDL_LIB
	mkdir -p $(INSTALL_IDL_LIB)
	rsync --times --cvs-exclude $(IDL_LIB) $(INSTALL_IDL_LIB)/
endif
ifdef CGI_BIN
	mkdir -p $(INSTALL_CGI_BIN)
	rsync --times --cvs-exclude $(CGI_BIN) $(INSTALL_CGI_BIN)/
endif
ifdef PERLLIB
	mkdir -p $(INSTALL_PERLLIB)
	rsync --times --cvs-exclude $(PERLLIB) $(INSTALL_PERLLIB)/
endif
ifdef WWW
	mkdir -p $(INSTALL_WWW)
	rsync --times --cvs-exclude $(WWW) $(INSTALL_WWW)/
endif

#rsync --times --cvs-exclude $(BIN) /data/mta4/space_weather/
#rsync --times --cvs-exclude $(DATA) /data/mta4/space_weather/
