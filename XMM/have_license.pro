FUNCTION HAVE_LICENSE,dummy
; do a simple test to see if we are running with an 
;  IDL license or in demo mode

;on_error,2
;on_ioerror,no_license
filename=strcompress('idl_ltest'+string(systime(1)),/remove_all)
openw,TEST,filename,/get_lun
printf,TEST,"IDL License check by have_license"
free_lun,TEST
spawn,"/bin/rm "+filename
return, 1

;no_license: return,0
end
