FUNCTION calc_grat_att, startt,stopt
; find attenuation factor between startt and stopt (in julian days)
files=findfile('/proj/sot/ska/data/arc/iFOT_events/grating/*.rdb')
print, "GRAT file ", files(n_elements(files)-1)
rdb_dat=rdb_read(files(n_elements(files)-1))
found=0
i=0
grat_time=0
duration=stopt-startt
while (found eq 0 and i lt n_elements(rdb_dat)-2) do begin
  rdb_time = strsplit(rdb_dat(i).TStart_GMT,":",/extract)
  yr=rdb_time(0)
  dd=rdb_time(1)
  hh=rdb_time(2)
  mm=rdb_time(3)
  print, yr,dd,hh,mm
  rdb_start_test= date_conv([yr,dd,hh,mm,'00'],"J")
  rdb_time = strsplit(rdb_dat(i+1).TStart_GMT,":",/extract)
  yr=rdb_time(0)
  dd=rdb_time(1)
  hh=rdb_time(2)
  mm=rdb_time(3)
  rdb_stop_test= date_conv([yr,dd,hh,mm,'00'],"J")
  if (rdb_start_test lt startt and rdb_stop_test gt startt and rdb_stop_test lt stopt) then begin
    case rdb_dat(i).GRATING_GRATING of
      "NONE": grat_time=grat_time+((rdb_stop_test-startt)/duration)
      "HETG": grat_time=grat_time+((rdb_stop_test-startt)/duration)*0.2
      "LETG": grat_time=grat_time+((rdb_stop_test-startt)/duration)*0.5
    endcase
  endif
  if (rdb_start_test lt startt and rdb_stop_test gt startt and rdb_stop_test gt stopt) then begin
    case rdb_dat(i).GRATING_GRATING of
      "NONE": grat_time=grat_time+1
      "HETG": grat_time=grat_time+0.2
      "LETG": grat_time=grat_time+0.5
    endcase
    found=1
  endif
  if (found eq 0 and rdb_start_test gt startt and rdb_stop_test lt stopt) then begin
    case rdb_dat(i).GRATING_GRATING of
      "NONE": grat_time=grat_time+((rdb_stop_test-rdb_start_test)/duration)
      "HETG": grat_time=grat_time+((rdb_stop_test-rdb_start_test)/duration)*0.2
      "LETG": grat_time=grat_time+((rdb_stop_test-rdb_start_test)/duration)*0.5
    endcase
  endif
  if (found eq 0 and rdb_start_test gt startt and rdb_stop_test gt stopt) then begin
    case rdb_dat(i).GRATING_GRATING of
      "NONE": grat_time=grat_time+((stopt-rdb_start_test)/duration)
      "HETG": grat_time=grat_time+((stopt-rdb_start_test)/duration)*0.2
      "LETG": grat_time=grat_time+((stopt-rdb_start_test)/duration)*0.5
    endcase
    found=1
  endif
  if (rdb_start_test gt stopt) then found=1
  i=i+1
endwhile
print, "Grat time ",grat_time,startt,stopt
return, grat_time
end

FUNCTION calc_att, startt,stopt
; find attenuation factor between startt and stopt (in julian days)
files=findfile('/proj/sot/ska/data/arc/iFOT_events/sim/*.rdb')
print, "SIM file ", files(n_elements(files)-1)
rdb_dat=rdb_read(files(n_elements(files)-1))
rdb_dat=rdb_dat(where(rdb_dat.Type_Description eq "SIM Translation"))
found=0
i=0
att_time=0
duration=stopt-startt
while (found eq 0 and i lt n_elements(rdb_dat)-2) do begin
  rdb_time = strsplit(rdb_dat(i).TStart_GMT,":",/extract)
  yr=rdb_time(0)
  dd=rdb_time(1)
  hh=rdb_time(2)
  mm=rdb_time(3)
  print, yr,dd,hh,mm
  rdb_start_test= date_conv([yr,dd,hh,mm,'00'],"J")
  rdb_time = strsplit(rdb_dat(i+1).TStart_GMT,":",/extract)
  yr=rdb_time(0)
  dd=rdb_time(1)
  hh=rdb_time(2)
  mm=rdb_time(3)
  rdb_stop_test= date_conv([yr,dd,hh,mm,'00'],"J")
  if (rdb_start_test lt startt and rdb_stop_test gt startt and rdb_stop_test lt stopt) then begin
    if (rdb_dat(i).SIMTRANS_POS gt 0) then begin
      att_time=att_time+(((rdb_stop_test-startt)/duration)*calc_grat_att(startt,rdb_stop_test))
    endif
  endif
  if (rdb_start_test lt startt and rdb_stop_test gt startt and rdb_stop_test gt stopt) then begin
    if (rdb_dat(i).SIMTRANS_POS gt 0) then begin
      att_time = att_time+calc_grat_att(startt,stopt)
      found=1
    endif
  endif
  if (found eq 0 and rdb_start_test gt startt and rdb_stop_test lt stopt) then begin
    if (rdb_dat(i).SIMTRANS_POS gt 0) then begin
      att_time = att_time+(((rdb_stop_test-rdb_start_test)/duration)*calc_grat_att(rdb_start_test,rdb_stop_test))
    endif
  endif
  if (found eq 0 and rdb_start_test gt startt and rdb_stop_test gt stopt) then begin
    if (rdb_dat(i).SIMTRANS_POS gt 0) then begin
      att_time = att_time+(((stopt-rdb_start_test)/duration)*calc_grat_att(rdb_start_test,stopt))
      found=1
    endif
  endif
  if (rdb_start_test gt stopt) then found=1
  i=i+1
endwhile
print, "ATT_TIME ", att_time,startt,stopt
return, att_time
end

PRO RAD_SUMM

readcol,"/proj/rac/ops/CRM3/CRMsummary.dat",infile,format="a",delimiter="ZZZ"
readcol,"/pool14/chandra/chandra_psi.snapshot",snapshot,format="a",delimiter="ZZZ"
readcol,"/proj/rac/ops/ACE/fluace.dat",ace,format="a",delimiter="ZZZ"
readcol,"/export/acis-flight/FLU-MON/current.dat",acis,format="a",delimiter="ZZZ"

;rdfloat,"/proj/sot/acis/FLU-MON/all.dat",yy,mm,dd,hm,doy,secs,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,skipline=5

;http://www.swpc.noaa.gov/ftpdir/lists/particle/Gp_part_5m.txt

orb_time= 228600L
;rad_time= 204600L-17500L  ; temp HRC attenuation for 2011:068 orbit

line= strsplit(infile(0),":",/extract)
config = line(1)

line= strsplit(infile(4),":",/extract)
goes_p2_flx = float(line(1))

line= strsplit(infile(5),":",/extract)
goes_p5_flx = float(line(1))

line= strsplit(infile(7),":",/extract)
goes_e2_flx = float(line(1))

line= strsplit(infile(8),":",/extract)
orb_start = strjoin(string(line[1:5]),":")

line= strsplit(infile(9),":",/extract)
alt = string(line(1))

line= strsplit(infile(11),":",/extract)
crm_flx = float(line(1))

line= strsplit(infile(12),":",/extract)
crm_flx_att = float(line(1))

line= strsplit(infile(13),":",/extract)
crm_flu = float(line(1))

line= strsplit(infile(14),":",/extract)
crm_flu_att = float(line(1))

line= strsplit(ace(4),/extract)
ace_p3_flx = line(11)

line= strsplit(ace(6),/extract)
ace_p3_flu = line(9)

line= strsplit(acis(n_elements(acis)-3),/extract)
ace_p3_flx_att = line(9)

line= strsplit(acis(n_elements(acis)-1),/extract)
ace_p3_flu_att = line(9)

att_factor= crm_flx_att/crm_flx
att_flu_factor= crm_flu_att/crm_flu
;calc_elapsed_time= crm_flu/crm_flx

jday= systime(/julian,/utc)
jorb_start= date_conv(strsplit(orb_start,":",/extract),"J")
elapsed_time=(jday-jorb_start)*86400L
time_to_per=orb_time-elapsed_time

; find radzone start and end times
files=findfile('/proj/sot/ska/data/arc/iFOT_events/radmon/*.rdb')
print, "Radmon file ", files(n_elements(files)-1)
rdb_dat=rdb_read(files(n_elements(files)-1))
;rdb_dat=rdb_dat(where(strmatch(rdb_dat.Type_Description,'*Disable') eq 1))
found=0
i=0
rad_end=0L
rad_end_str="NULL"
while (found eq 0 and i lt n_elements(rdb_dat)) do begin
  rdb_time = strsplit(rdb_dat(i).TStart_GMT,":",/extract)
  yr=rdb_time(0)
  dd=rdb_time(1)
  hh=rdb_time(2)
  mm=rdb_time(3)
  print, yr,dd,hh,mm
  rdb_start_test= date_conv([yr,dd,hh,mm,'00'],"J")
  rad_start=rad_end
  rad_start_str=rad_end_str
  rad_end_str=strjoin([yr,dd,hh,mm,'00'],":")
  rad_end=rdb_start_test
  if (rdb_start_test gt jday) then begin
    if (strmatch(rdb_dat(i).Type_Description,'*Disable') eq 1) then begin
      radzone=0
      found=1
    endif
    if (strmatch(rdb_dat(i).Type_Description,'*Enable') eq 1) then begin
      radzone=1 ; found=0 -> goto next disable
    endif
    print, "found rad ", i
  endif
  i=i+1
endwhile
time_to_rad=(rad_end-jday)*86400L
rad_time= (rad_end-rad_start)*86400L
calc_elapsed_time=max([(jday-rad_start)*86400L,0])
print, calc_elapsed_time,  jday, rad_start, rad_end, "elapsed time"

; find next 2 comm times
files=findfile('/proj/sot/ska/data/arc/iFOT_events/comm/*.rdb')
print, "Comm file ", files(n_elements(files)-1)
com_dat=rdb_read(files(n_elements(files)-1))
found=0
next_com=strarr(2)
jcom_start=[jday,jday]
time_to_com=lonarr(2)
i=0
while (found lt 2 and i lt n_elements(com_dat)-1) do begin
  comm_time = strsplit(com_dat(i).TStart_GMT,":",/extract)
  yr=comm_time(0)
  dd=comm_time(1)
  if (com_dat(i).DSN_COMM_bot gt 999) then begin
    hh = strmid(strtrim(com_dat(i).DSN_COMM_bot,1),0,2)
    mm = strmid(strtrim(com_dat(i).DSN_COMM_bot,1),2,2)
  endif else begin
    hh = strmid(strtrim(com_dat(i).DSN_COMM_bot,1),0,1)
    mm = strmid(strtrim(com_dat(i).DSN_COMM_bot,1),1,2)
  endelse
  print, yr,dd,hh,mm
  jcom_start_test= date_conv([yr,dd,hh,mm,'00'],"J")
  if (jcom_start_test gt jday) then begin
    next_com(found)=strjoin([yr,dd,hh,mm,'00'],":")
    jcom_start(found)=jcom_start_test
    time_to_com(found)=(jcom_start(found)-jday)*86400L
    found=found+1
    print, "found com ", i, found
  endif
  i=i+1
endwhile
print, "found com ", i, next_com(0),jcom_start(0),jday,time_to_com(0)
print, "found com ", i, next_com(1),jcom_start(1),jday,time_to_com(1)

att_time=time_to_rad*calc_att(jday,rad_end)
att_com_time=time_to_com(0)*calc_att(jday,jcom_start(0))
att_com2_time=time_to_com(1)*calc_att(jday,jcom_start(1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (time_to_rad lt 0) then time_to_rad = 0
if (time_to_com(0) lt 0) then time_to_com(0) = 0
if (time_to_com(1) lt 0) then time_to_com(1) = 0
print, elapsed_time,time_to_per,time_to_rad,att_time,rad_start,rad_end,rad_time,time_to_com(0),att_com_time,time_to_com(1),att_com2_time

crm_pflu= crm_flu+(crm_flx*time_to_rad)
crm_cflu= crm_flu+(crm_flx*time_to_com(0))
crm_c2flu= crm_flu+(crm_flx*time_to_com(1))
crm_pflu_att= crm_flu_att+(crm_flx*att_time)
crm_2pflu_att= crm_flu_att+(crm_flx*att_time*2)
crm_10pflu_att= crm_flu_att+(crm_flx*att_time*10)
crm_cflu_att= crm_flu_att+(crm_flx*att_com_time)
crm_c2flu_att= crm_flu_att+(crm_flx*att_com2_time)

ace_p3_pflu= ace_p3_flu+(ace_p3_flx*time_to_rad)
ace_p3_cflu= ace_p3_flu+(ace_p3_flx*time_to_com(0))
ace_p3_c2flu= ace_p3_flu+(ace_p3_flx*time_to_com(1))
ace_p3_pflu_att= ace_p3_flu_att+(ace_p3_flx*att_time)
ace_p3_2pflu_att= ace_p3_flu_att+(ace_p3_flx*att_time*2)
ace_p3_10pflu_att= ace_p3_flu_att+(ace_p3_flx*att_time*10)
ace_p3_cflu_att= ace_p3_flu_att+(ace_p3_flx*att_com_time)
ace_p3_c2flu_att= ace_p3_flu_att+(ace_p3_flx*att_com2_time)

goes_p2_flu= goes_p2_flx*elapsed_time
goes_p2_flx_att= goes_p2_flx*att_factor
goes_p2_flu_att= goes_p2_flu*att_flu_factor
goes_p2_pflu= goes_p2_flu+(goes_p2_flx*time_to_rad)
goes_p2_cflu= goes_p2_flu+(goes_p2_flx*time_to_com(0))
goes_p2_c2flu= goes_p2_flu+(goes_p2_flx*time_to_com(1))
goes_p2_pflu_att= goes_p2_flu_att+(goes_p2_flx*att_time)
goes_p2_cflu_att= goes_p2_flu_att+(goes_p2_flx*att_com_time)
goes_p2_c2flu_att= goes_p2_flu_att+(goes_p2_flx*att_com2_time)

goes_p5_flu= goes_p5_flx*elapsed_time
goes_p5_flx_att= goes_p5_flx*att_factor
goes_p5_flu_att= goes_p5_flu*att_flu_factor
goes_p5_pflu= goes_p5_flu+(goes_p5_flx*time_to_rad)
goes_p5_cflu= goes_p5_flu+(goes_p5_flx*time_to_com(0))
goes_p5_c2flu= goes_p5_flu+(goes_p5_flx*time_to_com(1))
goes_p5_pflu_att= goes_p5_flu_att+(goes_p5_flx*att_time)
goes_p5_cflu_att= goes_p5_flu_att+(goes_p5_flx*att_com_time)
goes_p5_c2flu_att= goes_p5_flu_att+(goes_p5_flx*att_com2_time)

goes_e2_flu= goes_e2_flx*elapsed_time
goes_e2_flx_att= goes_e2_flx*att_factor
goes_e2_flu_att= goes_e2_flu*att_flu_factor
goes_e2_pflu= goes_e2_flu+(goes_e2_flx*time_to_rad)
goes_e2_cflu= goes_e2_flu+(goes_e2_flx*time_to_com(0))
goes_e2_c2flu= goes_e2_flu+(goes_e2_flx*time_to_com(1))
goes_e2_pflu_att= goes_e2_flu_att+(goes_e2_flx*att_time)
goes_e2_cflu_att= goes_e2_flu_att+(goes_e2_flx*att_com_time)
goes_e2_c2flu_att= goes_e2_flu_att+(goes_e2_flx*att_com2_time)

line0= strsplit(snapshot(0),"()",/extract)
line1= strsplit(snapshot(1),/extract)
snap_time = strjoin([line1(1),line0(1)]," ")

line= strsplit(snapshot(18),/extract)
e150 = line(11)

line= strsplit(snapshot(20),/extract)
e1300 = line(7)

openw, OUT, "rad_summ.html", /get_lun
printf, OUT, '<html><head><title>Chandra Radiation Summary</title></head>'
printf, OUT, '<body bgcolor="#000000" text="#eeeeee">'
printf, OUT, '<h2>Chandra Radiation Environment Summary</h2>'
;printf, OUT, '<br />Orbit start: ', yy, mm, dd, hm,'<br />'
printf, OUT, '<br />Orbit start: ',orb_start,' (all times on this page are UTC) <br />'
printf, OUT, 'Current altitude (km) and orbit leg: ',alt,'<br />'
printf, OUT, 'Current configuration: ',config,'<br />'
printf, OUT, 'Next comm: ',next_com(0),' (',string(time_to_com(0)/3600.0,format='(F4.1)'),' hours) <br />'
printf, OUT, 'Next rad zone: ',rad_end_str,' (',string(time_to_rad/3600.0,format='(F4.1)'),' hours) <br />'
printf, OUT, 'Last updated: ', systime(/utc),'<br /><br />'
printf, OUT, '<table border=1>'
printf, OUT, '<tr><th>&#160</th><th colspan=6>Attenuated * projects fluences based on upcoming SI and grating configuration'
printf, OUT, '<br />ACIS effective exposure times (ks) '
;printf, OUT, '<br />ACIS effective exposure times (ks) &#160 &#160This orbit so far: ',string(calc_elapsed_time/1000.0,format='(F8.1)')
printf, OUT, '&#160 &#160 Until next radzone: ',string(att_time/1000.0,format='(F7.1)')
printf, OUT, '&#160 &#160 Until next comm: ',string(att_com_time/1000.0,format='(F7.1)')
printf, OUT, '</th></tr>'
printf, OUT, '<tr><th>&#160</th><th>2 hr ave. Flux</th><th>Current fluence<br />(total so far in current orbit)</th><th>Projected fluence<br /> until next rad zone</th><th>Projected fluence</th><th>Projected fluence</th><th>Limits</th>'
printf, OUT, '<tr><th>&#160</th><th>(p/cm^2-s-sr-MeV)</th><th>(p/cm^2-sr-MeV)</th><th>at current flux<br />(at 2X flux)<br/>*at 10X flux*</th><th>until next comm.</th><th>until second comm.</th><th>&#160</th>'
printf, OUT, '<tr><td>CRM</td>'
printf, OUT, '<td>',string(crm_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_pflu_att,format='(E9.3)')
printf, OUT, '<br />(',string(crm_2pflu_att,format='(E9.3)'),')'
printf, OUT, '<br />*',string(crm_10pflu_att,format='(E9.3)'),'*</td>'
printf, OUT, '<td>',string(crm_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_c2flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>ACE P3</td>'
printf, OUT, '<td>',string(ace_p3_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_pflu_att,format='(E9.3)')
printf, OUT, '<br />(',string(ace_p3_2pflu_att,format='(E9.3)'),')'
printf, OUT, '<br />*',string(ace_p3_10pflu_att,format='(E9.3)'),'*</td>'
printf, OUT, '<td>',string(ace_p3_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_c2flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>1.000E+09 (fluence)</td></tr>'

printf, OUT, '<tr><td>GOES-13 (P2)</td>'
printf, OUT, '<td>',string(goes_p2_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_pflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_c2flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>GOES-13 (P5)</td>'
printf, OUT, '<td>',string(goes_p5_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_pflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_c2flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>GOES-13 (E > 2.0 MeV)</td>'
printf, OUT, '<td>',string(goes_e2_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_pflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_c2flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

;printf, OUT, '<tr><td>CRM3</td>'
;printf, OUT, '<td>&#160</td>'
;printf, OUT, '<td>&#160</td>'
;printf, OUT, '<td>&#160</td>'
;printf, OUT, '<td>&#160</td>'
;printf, OUT, '<td>&#160</td>'
;printf, OUT, '<td>&#160</td>'
;printf, OUT, '<td>&#160</td>'
;printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><th colspan=7>&#160</th></tr>
printf, OUT, '<tr><th>&#160</th><th colspan=6>External - does not take into account the instrument configuration </th></tr>
printf, OUT, '<tr><th>&#160</th><th>2 hr ave. Flux</th><th>Current fluence <br />(total so far in current orbit)</th><th>Projected fluence</th><th>Projected fluence</th><th>&#160</th><th>Limits</th>'
printf, OUT, '<tr><th>&#160</th><th>(p/cm^2-s-sr-MeV)</th><th>(p/cm^2-sr-MeV)</th><th>until next radzone <br />(total for current orbit)</th><th>until next comm.</th><th>until second comm.</th><th>&#160</th>'
printf, OUT, '<tr><td>CRM</td>'
printf, OUT, '<td>',string(crm_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_c2flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>ACE P3</td>'
printf, OUT, '<td>',string(ace_p3_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_c2flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>3.6e8 (2 hr fluence, red)</td></tr>'

printf, OUT, '<tr><td>GOES-13 (P2)</td>'
printf, OUT, '<td>',string(goes_p2_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_c2flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>30.0/90.9 (flux, yellow/red)</td></tr>'

printf, OUT, '<tr><td>GOES-13 (P5)</td>'
printf, OUT, '<td>',string(goes_p5_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_c2flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>0.25/0.70 (flux, yellow/red)</td></tr>'

printf, OUT, '<tr><td>GOES-13 (E > 2.0 MeV)</td>'
printf, OUT, '<td>',string(goes_e2_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_c2flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>EPHIN E150 *</td>'
printf, OUT, '<td>',string(e150,format='(F8.1)'),'</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>&#160</td>'
printf, OUT, '<td>8.0e5 (radmon safing)</td></tr>'

printf, OUT, '<tr><td>EPHIN E1300 *</td>'
printf, OUT, '<td>',string(e1300,format='(F8.1)'),'</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>&#160</td>'
printf, OUT, '<td>&#160</td>'
printf, OUT, '<td>1000 (radmon safing)</td></tr>'
printf, OUT, '</table>'

printf, OUT, '<br />The current fluence is calculated from the beginning on the current orbit. The ACE P3 external fluence starts integrating above 70 kkm.'
;printf, OUT, '<br />The projected fluence is the total until the end of the orbit given the current flux.  (should be until rad zone entry)
printf, OUT, '<br />* EPHIN "fluxes" are raw counts as of the last support ['
printf, OUT, snap_time
printf, OUT, '], not averaged.'
printf, OUT, '<br /><br />'
printf, OUT, '<img src="/mta/RADIATION/CRM2/crmplatt.gif">'

printf, OUT, '</body></html>

close, OUT
;print, "time to com ",time_to_com

end

