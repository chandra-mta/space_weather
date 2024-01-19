PRO CALL_BRAD, msg
return
; send brad a one-line message, if you haven't sent it already
;  brad must re-arm manually be removing line from logfile

logfile="/home/mta/Logs/brad_msg"
tmplogfile=logfile+"xx"
readcol,logfile,logs,tstart,tstop,ntrig,format='a,a,a,i',skipline=2

; replace blank spaces

msg_str=strsplit(msg,/extract)
msg_log=msg_str(0)
for i=1,n_elements(msg_str)-1 do begin
  msg_log=msg_log+"_"+msg_str(i)
endfor ; for i=1,n_elements(msgs_str)-1 do begin

time=strsplit(systime(),/extract)
time_log=time(1)
for i=2,n_elements(time)-1 do begin
  time_log=time_log+"_"+time(i)
endfor ; for i=1,n_elements(time)-1 do begin

b=where(msg_log eq logs,bnum)
if (bnum eq 0) then begin ; message hasn't been sent
  openw,lunit,logfile,/append,/get_lun
  printf,lunit,format='(a," ",A," ",A," ",I6)',msg_log,time_log,time_log,1
  free_lun,lunit
  command='echo "'+msg+'" | mailx -s "call_brad_notice" brad'
  ;spawn, command
endif else begin ; if (bnum eq 0) then begin ; just record time, don't resend
  spawn, "head -6 "+logfile+" > "+tmplogfile
  openw,lunit,tmplogfile,/append,/get_lun
  for i=0,b(0)-1 do begin
    printf,lunit,format='(a," ",A," ",A," ",I6)',logs(i),tstart(i),tstop(i), ntrig(i)
  endfor ;for i=0,b(0)-1 do begin
  printf,lunit,format='(a," ",A," ",A," ",I6)',logs(b(0)),tstart(b(0)),time_log, ntrig(b(0))+1
  for i=b(0)+1,n_elements(logs)-1 do begin
    printf,lunit,format='(a," ",A," ",A," ",I6)',logs(i),tstart(i),tstop(i), ntrig(i)
  endfor ;for i=0,b(0)-1 do begin
  free_lun,lunit
  spawn,"mv "+tmplogfile+" "+logfile
endelse ; if (bnum eq 0) then begin ; message hasn't been sent

end
