PRO RAD_SUMM

readcol,"/proj/rac/ops/CRM3/CRMsummary.dat",infile,format="a",delimiter="ZZZ"
readcol,"/pool14/chandra/chandra_psi.snapshot",snapshot,format="a",delimiter="ZZZ"
readcol,"/proj/rac/ops/ACE/fluace.dat",ace,format="a",delimiter="ZZZ"

;rdfloat,"/proj/sot/acis/FLU-MON/all.dat",yy,mm,dd,hm,doy,secs,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,skipline=5

;http://www.swpc.noaa.gov/ftpdir/lists/particle/Gp_part_5m.txt

orb_time= 228600L
rad_time= 207720L
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

att_factor= crm_flx_att/crm_flx
att_flu_factor= crm_flu_att/crm_flu
calc_elapsed_time= crm_flu/crm_flx

jday= systime(/julian,/utc)
jorb_start= date_conv(strsplit(orb_start,":",/extract),"J")
next_com='2010:294:03:40:00'
jcom_start= date_conv(strsplit(next_com,":",/extract),"J")
elapsed_time=(jday-jorb_start)*86400L
time_to_per=orb_time-elapsed_time
time_to_rad=rad_time-elapsed_time

; find next comm time
files=findfile('/proj/sot/ska/data/arc/iFOT_events/comm/*.rdb')
print, "Comm file ", files(n_elements(files)-1)
;readcol, files(n_elements(files)-1),type,tstart,tstop,bot,eot,sta,config,site,supp,act,lga,soe, $
readcol, files(n_elements(files)-1),com_dat, $
    format="a", delimiter="ZZZ", skipline=2
found=0
i=0
while (found eq 0 and i lt n_elements(com_dat)) do begin
  yr=strmid(com_dat(i),14,4)
  dd=strmid(com_dat(i),19,3)
  hh=strmid(com_dat(i),58,2)
  mm=strmid(com_dat(i),60,2)
  print, yr,dd,hh,mm
  jcom_start_test= date_conv([yr,dd,hh,mm,'00'],"J")
  if (jcom_start_test gt jday) then begin
    next_com=strjoin([yr,dd,hh,mm,'00'],":")
    jcom_start=jcom_start_test
    time_to_com=(jcom_start-jday)*86400L
    found=1
    print, "found com ", i
  endif
  i=i+1
  print, "find com ", i
endwhile

;time_to_com=10800
print, elapsed_time, time_to_per, time_to_rad, rad_time, time_to_com

;;;;;;;;; for orbit starting 2011:068 - manually attenuate HRC
if (elapsed_time lt 31500) then time_to_rad = time_to_rad - 17500
if (elapsed_time gt 31500 and elapsed_time lt 31500+17500) then time_to_rad = 137040

;crm_flx_att = crm_flx
ace_p3_flx_att = ace_p3_flx
;ace_p3_flu_att = ace_p3_flu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (time_to_rad lt 0) then time_to_rad = 0
if (time_to_com lt 0) then time_to_com = 0

crm_pflu= crm_flu+(crm_flx*time_to_rad)
crm_cflu= crm_flu+(crm_flx*time_to_com)
crm_pflu_att= crm_flu_att+(crm_flx_att*time_to_rad)
;;crm_pflu_att= crm_flu_att+(crm_flx*time_to_rad) ; use until start of rad zone 2011:068
crm_2pflu_att= crm_flu_att+(crm_flx_att*time_to_rad*2)
;;crm_2pflu_att= crm_flu_att+(crm_flx*time_to_rad*2)
crm_10pflu_att= crm_flu_att+(crm_flx_att*time_to_rad*10)
;;crm_10pflu_att= crm_flu_att+(crm_flx*time_to_rad*10)
crm_cflu_att= crm_flu_att+(crm_flx_att*time_to_com)
;;crm_cflu_att= crm_flu_att+(crm_flx*time_to_com)

;;ace_p3_flx_att= ace_p3_flx*att_factor
ace_p3_flu_att= ace_p3_flu*att_flu_factor
ace_p3_pflu= ace_p3_flu+(ace_p3_flx*time_to_rad)
ace_p3_cflu= ace_p3_flu+(ace_p3_flx*time_to_com)
ace_p3_pflu_att= ace_p3_flu_att+(ace_p3_flx_att*time_to_rad)
;;ace_p3_pflu_att= ace_p3_flu_att+(ace_p3_flx*time_to_rad)
ace_p3_2pflu_att= ace_p3_flu_att+(ace_p3_flx_att*time_to_rad*2)
;;ace_p3_2pflu_att= ace_p3_flu_att+(ace_p3_flx*time_to_rad*2)
ace_p3_10pflu_att= ace_p3_flu_att+(ace_p3_flx_att*time_to_rad*10)
;;ace_p3_10pflu_att= ace_p3_flu_att+(ace_p3_flx*time_to_rad*10)
ace_p3_cflu_att= ace_p3_flu_att+(ace_p3_flx_att*time_to_com)
;;ace_p3_cflu_att= ace_p3_flu_att+(ace_p3_flx*time_to_com)

goes_p2_flu= goes_p2_flx*elapsed_time
goes_p2_flx_att= goes_p2_flx*att_factor
goes_p2_flu_att= goes_p2_flu*att_flu_factor
goes_p2_pflu= goes_p2_flu+(goes_p2_flx*time_to_rad)
goes_p2_cflu= goes_p2_flu+(goes_p2_flx*time_to_com)
goes_p2_pflu_att= goes_p2_flu_att+(goes_p2_flx_att*time_to_rad)
goes_p2_cflu_att= goes_p2_flu_att+(goes_p2_flx_att*time_to_com)

goes_p5_flu= goes_p5_flx*elapsed_time
goes_p5_flx_att= goes_p5_flx*att_factor
goes_p5_flu_att= goes_p5_flu*att_flu_factor
goes_p5_pflu= goes_p5_flu+(goes_p5_flx*time_to_rad)
goes_p5_cflu= goes_p5_flu+(goes_p5_flx*time_to_com)
goes_p5_pflu_att= goes_p5_flu_att+(goes_p5_flx_att*time_to_rad)
goes_p5_cflu_att= goes_p5_flu_att+(goes_p5_flx_att*time_to_com)

goes_e2_flu= goes_e2_flx*elapsed_time
goes_e2_flx_att= goes_e2_flx*att_factor
goes_e2_flu_att= goes_e2_flu*att_flu_factor
goes_e2_pflu= goes_e2_flu+(goes_e2_flx*time_to_rad)
goes_e2_cflu= goes_e2_flu+(goes_e2_flx*time_to_com)
goes_e2_pflu_att= goes_e2_flu_att+(goes_e2_flx_att*time_to_rad)
goes_e2_cflu_att= goes_e2_flu_att+(goes_e2_flx_att*time_to_com)

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
printf, OUT, 'Next comm: ',next_com,' (',string(time_to_com/3600.0,format='(F4.1)'),' hours )<br />'
printf, OUT, 'Next rad zone in ',string(time_to_rad/3600.0,format='(F4.1)'),' hours<br />'
printf, OUT, 'Last updated: ', systime(/utc),'<br /><br />'
printf, OUT, '<table border=1>'
printf, OUT, '<tr><th>&#160</th><th colspan=5>Attenuated * ACE P3 accurately projects fluences based on upcoming SI/Grating configuration.  <br />The others currently assume current configuration for the rest of the orbit (accurate projection in work.)</th></tr>
printf, OUT, '<tr><th>&#160</th><th>2 hr ave. Flux</th><th>Current fluence<br />(total so far in current orbit)</th><th>Projected fluence<br /> until next rad zone</th><th>Projected fluence</th><th>Limits</th>'
printf, OUT, '<tr><th>&#160</th><th>(p/cm^2-s-sr-MeV)</th><th>(p/cm^2-sr-MeV)</th><th>at current flux<br />(at 2X flux)<br/>*at 10X flux*</th><th>until next comm.</th><th>&#160</th>'
printf, OUT, '<tr><td>CRM</td>'
printf, OUT, '<td>',string(crm_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_pflu_att,format='(E9.3)')
printf, OUT, '<br />(',string(crm_2pflu_att,format='(E9.3)'),')'
printf, OUT, '<br />*',string(crm_10pflu_att,format='(E9.3)'),'*</td>'
printf, OUT, '<td>',string(crm_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>ACE P3</td>'
printf, OUT, '<td>',string(ace_p3_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_pflu_att,format='(E9.3)')
printf, OUT, '<br />(',string(ace_p3_2pflu_att,format='(E9.3)'),')'
printf, OUT, '<br />*',string(ace_p3_10pflu_att,format='(E9.3)'),'*</td>'
printf, OUT, '<td>',string(ace_p3_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>1.000E+09 (fluence)</td></tr>'

printf, OUT, '<tr><td>GOES-13 (P2)</td>'
printf, OUT, '<td>',string(goes_p2_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_pflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>GOES-13 (P5)</td>'
printf, OUT, '<td>',string(goes_p5_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_pflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_cflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>GOES-13 (E > 2.0 MeV)</td>'
printf, OUT, '<td>',string(goes_e2_flx_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_flu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_pflu_att,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_cflu_att,format='(E9.3)'),'</td>'
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

printf, OUT, '<tr><th colspan=6>&#160</th></tr>
printf, OUT, '<tr><th>&#160</th><th colspan=5>External - does not take into account the instrument configuration </th></tr>
printf, OUT, '<tr><th>&#160</th><th>2 hr ave. Flux</th><th>Current fluence <br />(total so far in current orbit)</th><th>Projected fluence</th><th>Projected fluence</th><th>Limits</th>'
printf, OUT, '<tr><th>&#160</th><th>(p/cm^2-s-sr-MeV)</th><th>(p/cm^2-sr-MeV)</th><th>until next radzone <br />(total for current orbit)</th><th>until next comm.</th><th>&#160</th>'
printf, OUT, '<tr><td>CRM</td>'
printf, OUT, '<td>',string(crm_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(crm_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>ACE P3</td>'
printf, OUT, '<td>',string(ace_p3_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(ace_p3_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>3.6e8 (2 hr fluence, red)</td></tr>'

printf, OUT, '<tr><td>GOES-13 (P2)</td>'
printf, OUT, '<td>',string(goes_p2_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p2_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>30.0/90.9 (flux, yellow/red)</td></tr>'

printf, OUT, '<tr><td>GOES-13 (P5)</td>'
printf, OUT, '<td>',string(goes_p5_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_p5_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>0.25/0.70 (flux, yellow/red)</td></tr>'

printf, OUT, '<tr><td>GOES-13 (E > 2.0 MeV)</td>'
printf, OUT, '<td>',string(goes_e2_flx,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_flu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_pflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>',string(goes_e2_cflu,format='(E9.3)'),'</td>'
printf, OUT, '<td>&#160</td></tr>'

printf, OUT, '<tr><td>EPHIN E150 *</td>'
printf, OUT, '<td>',string(e150,format='(F8.1)'),'</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>8.0e5 (radmon safing)</td></tr>'

printf, OUT, '<tr><td>EPHIN E1300 *</td>'
printf, OUT, '<td>',string(e1300,format='(F8.1)'),'</td>'
printf, OUT, '<td>N/A</td>'
printf, OUT, '<td>N/A</td>'
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
