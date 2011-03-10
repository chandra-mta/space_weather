FUNCTION rdb_read, file_name, SILENT = silent, $
	PHA = pha, COL_TYPES = col_types, $
	HEADER=header
;
; Procedure to read in an rdb file into an
; IDL structure where the tags are the column
; names.
;
; USAGE:
;   IDL>  data = rdb_read('file_name')
; 
; KEYWORDs:
;   /SILENT will supress the print statements
;   /PHA will set default column type to N
;   COL_TYPES=['N','S','S'] will explicitly set
;                         the column type.
;   HEADER = string array, one element per line of header
;
; 3/27/97 dd Initial version
; 6/23/97 modified by dph to remove spawns to unix
; 9/23/97 dd slight tweaks for CAT release
; 4/16/98 dd Modified to create function (rdb_structtemp.pro)
;             to define the structure when the EXECUTE 131
;             character limit is exceeded, a la mrd_struct.pro
;             in lib_astro/pro/structure.
; 1999-01-16 dd Add a HEADER keyword to provide the head to
;               the calling routine.

   on_error, 2                  ; stay here?
   
; Open the file
   OPENR, unit, file_name, /GET_LUN
   
   lines = 0L                   ; in case more than 32K lines
   sline = ''                   ; define a string variable for one line
   WHILE NOT eof(unit) DO BEGIN ; this probably takes time on big files.
                                ; FSTAT will tell me how many bytes
                                ; there are, but not lines.
      readf, unit, sline 
      lines = lines+1L
   ENDWHILE
   
   if NOT(KEYWORD_SET(SILENT)) then print, $
    'File '+file_name+' has ', lines, ' lines'
   
   point_lun, unit, 0           ; "rewind" the file
   
; Get the column names...
; Skip any #-started lines
   test = 0
   line_in = ''
   header=STRARR(1000) 
   ih = 0
   while test EQ 0 do begin
      READF, unit, line_in
      test = STRPOS(line_in,'#')
      header(ih) = line_in
      ih = ih+1
   end
   if ih GE 2 then header = header(0:ih-2) else header=['#']
   col_names = STR_SEP(line_in,STRING(9B))
   if NOT(KEYWORD_SET(SILENT)) then print, col_names
   
; Read column data types line
   READF, unit, line_in
   line_sepped = STR_SEP(line_in,STRING(9B))

; Are the column types specified with the call?
   if KEYWORD_SET(COL_TYPES) then begin
     ; col_types is set so need to do nothing more...
   end else begin
     ; figure out the column types...
     ; Set defaults for the column types
     if KEYWORD_SET(PHA) then begin
        ; MST files have --- instead of an N or S
        ; PHA files are all numeric ...
        col_types = 'N' + STRARR(n_elements(line_sepped))
     end else begin
        col_types = 'S' + STRARR(n_elements(line_sepped))
     end
     ; set the columns using the rdb line information 
     ; Set N columns
     num_cols = where(STRPOS(line_sepped,'N') GE 0, n_num_cols)
     if n_num_cols GE 1 then begin
        col_types(num_cols) = 'N'
     end
     ; Set S columns
     str_cols = where(STRPOS(line_sepped,'S') GE 0, n_str_cols)
     if n_str_cols GE 1 then begin
        col_types(str_cols) = 'S'
     end
   end  ; end of setting col types

   if NOT(KEYWORD_SET(SILENT)) then print, col_types
   
; a little error checking here
   if n_elements(col_names) NE n_elements(col_types) then begin
                                ; bummer
      print, 'rdb_read: name and types with different lengths?!'
      RETURN, 0.0
   end
   
; Define the structure
   struct_defn = ''
   for ic=0,n_elements(col_names)-1 do begin
      if ic NE 0 then struct_defn = struct_defn + ', '
      type_str = "''"
      if STRPOS(col_types(ic),'N') GE 0 then type_str = '0.0'
      struct_defn = struct_defn + col_names(ic) + ':' + type_str
   end
   
; Now assemble the IDL line to create the structure
   define_string = 'rdb_struct_defn = {' + struct_defn + '}'
   ; EXECUTE only works for 131 characters or less so, following
   ; lead of mrd_fstruct in mrd_struct.pro (lib_astro/pro/structure)
   ; we create and compile a little function to return the structure:
   if STRLEN(define_string) LE 131 then begin
     define_ok = EXECUTE(define_string)
     if define_ok EQ 0 then begin
                                ; bummer
       print, "rdb_read: EXECUTE failed for structure definition."
       RETURN, 0.0
     end
   end else begin
     ; create a temporary function...
     proname = 'rdb_structtemp'
     filenametemp = proname + '.pro'
     openw, lun, filenametemp, /get_lun
     printf, lun, 'FUNCTION '+proname
     printf, lun, 'RETURN, $'
     printf, lun, '{$'
     ; put in all the name, value pairs:
     n_col = n_elements(col_names)
     for ic=0,n_col-1 do begin
       type_str = "''"
       if STRPOS(col_types(ic),'N') GE 0 then type_str = '0.0'
       temp_defn = col_names(ic) + ':' + type_str
       if ic NE n_col-1 then temp_defn = temp_defn + ','
       temp_defn = temp_defn + ' $'
       printf, lun, temp_defn
     end
     ; all done
     printf, lun, '}'
     printf, lun, 'END'
     free_lun, lun
     resolve_routine, proname, /is_function
     rdb_struct_defn = call_function(proname)
;;   spawn, 'rm '+filenametemp
   end
   ; In anycase do the replication of the structure here with an 
   ; EXECUTE
   create_string = 'rdb_struct = REPLICATE( rdb_struct_defn, lines)'
   create_ok = EXECUTE(create_string)
   if create_ok EQ 0 then begin
                                ; bummer
      print, "rdb_read: EXECUTE failed for structure replication."
      RETURN, 0.0
   end
   
; Read in the data from the file
   n_names = n_elements(col_names)
   id = LONG(0)
   while NOT( EOF(unit) ) do begin
      READF, unit, line_in
      line_sepped = STR_SEP(line_in, STRING(9B))
                                ; a little more error checking here
      if n_names NE n_elements(line_sepped) then begin
                                ; bummer again
        ; Help diagnose the problem...
        print, ' - - - - - - rdb sleuth time - - - - - -'
        print, 'rdb_read: Found wrong number of columns on data-line :'+ $
		STRING(id)
        print, '          (add 3 plus the number of comment lines to get the file line number)'
        print, '          Expected : ',STRING(n_names), ' columns'
        print, '          Found : ',STRING(n_elements(line_sepped)), $
					' tab-delimited items'
        print, "          Here's the input line (in []s) : "
        print, '['+line_in+']'
        print, "          Here's the match up name to item :"
        print, ' column name : value in line'
        for iin=0, ((n_elements(line_sepped)-1) < (n_names-1)) do begin
          print, col_names(iin), ' : ', line_sepped(iin)
        end
        print, ' - - - - - - good luck sleuthing - - - - - -'
        RETURN, 0.0
      end
                                ; Load the values in
      for ic=0,n_names-1 do begin
         if col_types(ic) EQ 'N' then begin
            dummy = 0.0
            these_chars = line_sepped(ic)
            if these_chars EQ '' OR STRPOS(these_chars,'/') GE 0 OR $
             STRPOS(these_chars,'?') GE 0 then begin
                                ; no numeric data, use 0.0
               dummy = 0.0
            end else begin
                ; Useful to uncomment if a "N" column gets in trouble...
                ;;print, id, ic, ':  ['+these_chars+']'
               READS, these_chars, dummy
            end
            rdb_struct(id).(ic) = dummy
         end else begin
            rdb_struct(id).(ic) = line_sepped(ic)
         end
      end
      id = id + 1               ; next one
   end
   
   close, unit
   free_lun, unit
   
; Shorten to the correct length
   rdb_struct = rdb_struct(0:id-1)
   
   RETURN, rdb_struct
END
