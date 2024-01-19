function convert_to_host, input
datatypecode = size(input, /type)
case datatypecode of
    2 : byteorder, input, /ntohs
    3 : byteorder, input, /ntohl
    4 : byteorder, input, /xdrtof
    5 : byteorder, input, /xdrtod
    6 : begin
            r = float(input)
            i = imaginary(input)
            byteorder, r, i, /xdrtof
            input = complex(r, i)
        end
    9 : begin
            r = double(input)
            i = imaginary(input)
            byteorder, r, i, /xdrtod
            input = dcomplex(r, i)
        end
   12 : byteorder, input, /ntohs
   13 : byteorder, input, /ntohl
   14 : byteorder, input, /l64swap, /swap_if_little_endian
   15 : byteorder, input, /l64swap, /swap_if_little_endian
 else :
endcase
return, input
end
;
function read_ephemeris, ephemeris, print = print, rec = rec
;
if n_elements(rec) eq 0 then rec = 0
;
record_1_struct = {record_1, $
    odb_ephem_tape_id                  : 0.0d0, $
    odb_ephem_satellite_id             : 0.0d0, $
    odb_ephem_utc_flag                 : 0.0d0, $
    odb_ephem_start_date               : 0.0d0, $
    odb_ephem_start_day_count          : 0.0d0, $
    odb_ephem_start_sec_count          : 0.0d0, $
    odb_ephem_stop_date                : 0.0d0, $
    odb_ephem_stop_day_count           : 0.0d0, $
    odb_ephem_stop_sec_count           : 0.0d0, $
    odb_ephem_step_size                : 0.0d0, $
    odb_ephem_rec1_spare1              : bytarr(136), $
    odb_ephem_ref_date                 : 0.0d0, $
    odb_ephem_coord_type               : 0L, $
    odb_ephem_rec1_spare2              : bytarr(132), $
    odb_ephem_epoch_time               : 0.0d0, $
    odb_ephem_epoch_year               : 0.0d0, $
    odb_ephem_epoch_month              : 0.0d0, $
    odb_ephem_epoch_day                : 0.0d0, $
    odb_ephem_epoch_hour               : 0.0d0, $
    odb_ephem_epoch_min                : 0.0d0, $
    odb_ephem_epoch_millisec           : 0.0d0, $
    odb_ephem_smajor_axis              : 0.0d0, $
    odb_ephem_eccent                   : 0.0d0, $
    odb_ephem_inclin                   : 0.0d0, $
    odb_ephem_perigee                  : 0.0d0, $
    odb_ephem_raan                     : 0.0d0, $
    odb_ephem_mean_anom                : 0.0d0, $
    odb_ephem_true_anom                : 0.0d0, $
    odb_ephem_sum_aprgta               : 0.0d0, $
    odb_ephem_rec1_spare6              : bytarr(16), $
    odb_ephem_period                   : 0.0d0, $
    odb_ephem_rec1_spare7              : bytarr(16), $
    odb_ephem_mean_motn                : 0.0d0, $
    odb_ephem_rec1_spare8              : bytarr(8), $
    odb_ephem_rate_ascnd               : 0.0d0, $
    odb_ephem_pos_vector               : dblarr(3), $
    odb_ephem_vel_vector               : dblarr(3), $
    odb_ephem_rec1_spare3              : bytarr(456), $
    odb_ephem_solar_pos                : dblarr(3), $
    odb_ephem_rec1_spare4              : bytarr(520), $
    odb_ephem_grhour_angle             : 0.0d0, $
    odb_ephem_rec1_spare5              : bytarr(1200)}
;
record_2_struct = {record_2, $
    odb_ephem_rec2_spare1              : bytarr(2800)}
;
record_3_struct = {record_3, $
    odb_ephem_date_first_point         : 0.0d0, $
    junk1                              : 0L, $
    odb_ephem_days_in_year_first_point : 0L, $
    junk2                              : 0L, $
    odb_ephem_sec_in_day_first_point   : 0L, $
    odb_ephem_step_time                : 0.0d0, $
    odb_ephem_first_pos_vector         : dblarr(3), $
    odb_ephem_first_vel_vector         : dblarr(3), $
    odb_ephem_pos_vel_data_2_50        : dblarr(6, 49), $
    odb_ephem_rec3_spare1              : bytarr(368)}
;
record_4_struct = {record_4, $
    odb_ephem_sentinel                 : dblarr(10), $
    odb_ephem_rec4_spare1              : bytarr(2720)}
;
openr, lun, ephemeris, /get_lun
ephem = assoc(lun, bytarr(2800))
record = ephem(rec)
free_lun, lun
;
if rec eq 0 then begin
    record_type = 1
    record_1_struct.odb_ephem_tape_id                  = convert_to_host(double(record, 0))
    record_1_struct.odb_ephem_satellite_id             = convert_to_host(double(record, 8))
    record_1_struct.odb_ephem_utc_flag                 = convert_to_host(double(record, 16))
    record_1_struct.odb_ephem_start_date               = convert_to_host(double(record, 24))
    record_1_struct.odb_ephem_start_day_count          = convert_to_host(double(record, 32))
    record_1_struct.odb_ephem_start_sec_count          = convert_to_host(double(record, 40))
    record_1_struct.odb_ephem_stop_date                = convert_to_host(double(record, 48))
    record_1_struct.odb_ephem_stop_day_count           = convert_to_host(double(record, 56))
    record_1_struct.odb_ephem_stop_sec_count           = convert_to_host(double(record, 64))
    record_1_struct.odb_ephem_step_size                = convert_to_host(double(record, 72))
    record_1_struct.odb_ephem_rec1_spare1              = convert_to_host(byte(record, 80, 136))
    record_1_struct.odb_ephem_ref_date                 = convert_to_host(double(record, 216))
    record_1_struct.odb_ephem_coord_type               = convert_to_host(long(record, 224))
    record_1_struct.odb_ephem_rec1_spare2              = convert_to_host(byte(record, 228, 132))
    record_1_struct.odb_ephem_epoch_time               = convert_to_host(double(record, 360))
    record_1_struct.odb_ephem_epoch_year               = convert_to_host(double(record, 368))
    record_1_struct.odb_ephem_epoch_month              = convert_to_host(double(record, 376))
    record_1_struct.odb_ephem_epoch_day                = convert_to_host(double(record, 384))
    record_1_struct.odb_ephem_epoch_hour               = convert_to_host(double(record, 392))
    record_1_struct.odb_ephem_epoch_min                = convert_to_host(double(record, 400))
    record_1_struct.odb_ephem_epoch_millisec           = convert_to_host(double(record, 408))
    record_1_struct.odb_ephem_smajor_axis              = convert_to_host(double(record, 416))
    record_1_struct.odb_ephem_eccent                   = convert_to_host(double(record, 424))
    record_1_struct.odb_ephem_inclin                   = convert_to_host(double(record, 432))
    record_1_struct.odb_ephem_perigee                  = convert_to_host(double(record, 440))
    record_1_struct.odb_ephem_raan                     = convert_to_host(double(record, 448))
    record_1_struct.odb_ephem_mean_anom                = convert_to_host(double(record, 456))
    record_1_struct.odb_ephem_true_anom                = convert_to_host(double(record, 464))
    record_1_struct.odb_ephem_sum_aprgta               = convert_to_host(double(record, 472))
    record_1_struct.odb_ephem_rec1_spare6              = convert_to_host(byte(record, 480, 16))
    record_1_struct.odb_ephem_period                   = convert_to_host(double(record, 496))
    record_1_struct.odb_ephem_rec1_spare7              = convert_to_host(byte(record, 504, 16))
    record_1_struct.odb_ephem_mean_motn                = convert_to_host(double(record, 520))
    record_1_struct.odb_ephem_rec1_spare8              = convert_to_host(byte(record, 528, 8))
    record_1_struct.odb_ephem_rate_ascnd               = convert_to_host(double(record, 536))
    record_1_struct.odb_ephem_pos_vector               = convert_to_host(double(record, 544, 3))
    record_1_struct.odb_ephem_vel_vector               = convert_to_host(double(record, 568, 3))
    record_1_struct.odb_ephem_rec1_spare3              = convert_to_host(byte(record, 592, 456))
    record_1_struct.odb_ephem_solar_pos                = convert_to_host(double(record, 1048, 3))
    record_1_struct.odb_ephem_rec1_spare4              = convert_to_host(byte(record, 1072, 520))
    record_1_struct.odb_ephem_grhour_angle             = convert_to_host(double(record, 1592))
    record_1_struct.odb_ephem_rec1_spare5              = convert_to_host(byte(record, 1600, 1200))
endif else if rec eq 1 then begin
    record_type = 2
    record_2_struct.odb_ephem_rec2_spare1              = convert_to_host(byte(record, 0, 2800))
endif else begin
    sentinels = convert_to_host(double(record, 0, 10))
    if total(sentinels - replicate(0.9999999999999999d16, 10)) ne 0.0d0 then begin
        record_type = 3
        record_3_struct.odb_ephem_date_first_point         = convert_to_host(double(record, 0))
        record_3_struct.junk1                              = convert_to_host(long(record, 8))
        record_3_struct.odb_ephem_days_in_year_first_point = convert_to_host(long(record, 12))
        record_3_struct.junk2                              = convert_to_host(long(record, 16))
        record_3_struct.odb_ephem_sec_in_day_first_point   = convert_to_host(long(record, 20))
        record_3_struct.odb_ephem_step_time                = convert_to_host(double(record, 24))
        record_3_struct.odb_ephem_first_pos_vector         = convert_to_host(double(record, 32, 3))
        record_3_struct.odb_ephem_first_vel_vector         = convert_to_host(double(record, 56, 3))
        record_3_struct.odb_ephem_pos_vel_data_2_50        = convert_to_host(double(record, 80, 6, 49))
        record_3_struct.odb_ephem_rec3_spare1              = convert_to_host(byte(record, 2432, 368))
    endif else begin
        record_type = 4
        record_4_struct.odb_ephem_sentinel                 = sentinels
        record_4_struct.odb_ephem_rec4_spare1              = convert_to_host(byte(record, 80, 2720))
    endelse
endelse
;
case record_type of
    1: begin
        if keyword_set(print) then begin
            print, 'odb_ephem_tape_id                  : ', record_1_struct.odb_ephem_tape_id,                  format = '(a, d24.10)'
            print, 'odb_ephem_satellite_id             : ', record_1_struct.odb_ephem_satellite_id,             format = '(a, d24.10)'
            print, 'odb_ephem_utc_flag                 : ', record_1_struct.odb_ephem_utc_flag,                 format = '(a, d24.10)'
            print, 'odb_ephem_start_date               : ', record_1_struct.odb_ephem_start_date,               format = '(a, d24.10)'
            print, 'odb_ephem_start_day_count          : ', record_1_struct.odb_ephem_start_day_count,          format = '(a, d24.10)'
            print, 'odb_ephem_start_sec_count          : ', record_1_struct.odb_ephem_start_sec_count,          format = '(a, d24.10)'
            print, 'odb_ephem_stop_date                : ', record_1_struct.odb_ephem_stop_date,                format = '(a, d24.10)'
            print, 'odb_ephem_stop_day_count           : ', record_1_struct.odb_ephem_stop_day_count,           format = '(a, d24.10)'
            print, 'odb_ephem_stop_sec_count           : ', record_1_struct.odb_ephem_stop_sec_count,           format = '(a, d24.10)'
            print, 'odb_ephem_step_size                : ', record_1_struct.odb_ephem_step_size,                format = '(a, d24.10)'
;            print, 'odb_ephem_rec1_spare1              : ', record_1_struct.odb_ephem_rec1_spare1,              format = '(a, 136i4.3)'
            print, 'odb_ephem_ref_date                 : ', record_1_struct.odb_ephem_ref_date,                 format = '(a, d24.10)'
            print, 'odb_ephem_coord_type               : ', record_1_struct.odb_ephem_coord_type,               format = '(a, i24)'
;            print, 'odb_ephem_rec1_spare2              : ', record_1_struct.odb_ephem_rec1_spare2,              format = '(a, 132i4.3)'
            print, 'odb_ephem_epoch_time               : ', record_1_struct.odb_ephem_epoch_time,               format = '(a, d24.10)'
            print, 'odb_ephem_epoch_year               : ', record_1_struct.odb_ephem_epoch_year,               format = '(a, d24.10)'
            print, 'odb_ephem_epoch_month              : ', record_1_struct.odb_ephem_epoch_month,              format = '(a, d24.10)'
            print, 'odb_ephem_epoch_day                : ', record_1_struct.odb_ephem_epoch_day,                format = '(a, d24.10)'
            print, 'odb_ephem_epoch_hour               : ', record_1_struct.odb_ephem_epoch_hour,               format = '(a, d24.10)'
            print, 'odb_ephem_epoch_min                : ', record_1_struct.odb_ephem_epoch_min,                format = '(a, d24.10)'
            print, 'odb_ephem_epoch_millisec           : ', record_1_struct.odb_ephem_epoch_millisec,           format = '(a, d24.10)'
            print, 'odb_ephem_smajor_axis              : ', record_1_struct.odb_ephem_smajor_axis,              format = '(a, d24.10)'
            print, 'odb_ephem_eccent                   : ', record_1_struct.odb_ephem_eccent,                   format = '(a, d24.10)'
            print, 'odb_ephem_inclin                   : ', record_1_struct.odb_ephem_inclin,                   format = '(a, d24.10)'
            print, 'odb_ephem_perigee                  : ', record_1_struct.odb_ephem_perigee,                  format = '(a, d24.10)'
            print, 'odb_ephem_raan                     : ', record_1_struct.odb_ephem_raan,                     format = '(a, d24.10)'
            print, 'odb_ephem_mean_anom                : ', record_1_struct.odb_ephem_mean_anom,                format = '(a, d24.10)'
            print, 'odb_ephem_true_anom                : ', record_1_struct.odb_ephem_true_anom,                format = '(a, d24.10)'
            print, 'odb_ephem_sum_aprgta               : ', record_1_struct.odb_ephem_sum_aprgta,               format = '(a, d24.10)'
;            print, 'odb_ephem_rec1_spare6              : ', record_1_struct.odb_ephem_rec1_spare6,              format = '(a, 16i4.3)'
            print, 'odb_ephem_period                   : ', record_1_struct.odb_ephem_period,                   format = '(a, d24.10)'
;            print, 'odb_ephem_rec1_spare7              : ', record_1_struct.odb_ephem_rec1_spare7,              format = '(a, 16i4.3)'
            print, 'odb_ephem_mean_motn                : ', record_1_struct.odb_ephem_mean_motn,                format = '(a, g24.12)'
;            print, 'odb_ephem_rec1_spare8              : ', record_1_struct.odb_ephem_rec1_spare8,              format = '(a, 8i4.3)'
            print, 'odb_ephem_rate_ascnd               : ', record_1_struct.odb_ephem_rate_ascnd,               format = '(a, g24.12)'
            print, 'odb_ephem_pos_vector               : ', record_1_struct.odb_ephem_pos_vector,               format = '(a, 3d24.10)'
            print, 'odb_ephem_vel_vector               : ', record_1_struct.odb_ephem_vel_vector,               format = '(a, 3g24.12)'
;            print, 'odb_ephem_rec1_spare3              : ', record_1_struct.odb_ephem_rec1_spare3,              format = '(a, 456i4.3)'
            print, 'odb_ephem_solar_pos                : ', record_1_struct.odb_ephem_solar_pos,                format = '(a, 3g24.12)'
;            print, 'odb_ephem_rec1_spare4              : ', record_1_struct.odb_ephem_rec1_spare4,              format = '(a, 520i4.3)'
            print, 'odb_ephem_grhour_angle             : ', record_1_struct.odb_ephem_grhour_angle,             format = '(a, d24.10)'
;            print, 'odb_ephem_rec1_spare5              : ', record_1_struct.odb_ephem_rec1_spare5,              format = '(a, 1204i4.3)'
        endif
        return, record_1_struct
    end
    2: begin
        if keyword_set(print) then begin
;            print, 'odb_ephem_rec2_spare1              : ', record_2_struct.odb_ephem_rec2_spare1,              format = '(a, 2800i4.3)'
        endif
        return, record_2_struct
    end
    3: begin
        if keyword_set(print) then begin
            print, 'odb_ephem_date_first_point         : ', record_3_struct.odb_ephem_date_first_point,         format = '(a, d24.10)'
            print, 'junk1                              : ', record_3_struct.junk1,                              format = '(a, i24)'
            print, 'odb_ephem_days_in_year_first_point : ', record_3_struct.odb_ephem_days_in_year_first_point, format = '(a, i24)'
            print, 'junk2                              : ', record_3_struct.junk2,                              format = '(a, i24)'
            print, 'odb_ephem_sec_in_day_first_point   : ', record_3_struct.odb_ephem_sec_in_day_first_point,   format = '(a, i24)'
            print, 'odb_ephem_step_time                : ', record_3_struct.odb_ephem_step_time,                format = '(a, d24.10)'
            print, 'odb_ephem_first_pos_vector         : ', record_3_struct.odb_ephem_first_pos_vector,         format = '(a, 3g24.12)'
            print, 'odb_ephem_first_vel_vector         : ', record_3_struct.odb_ephem_first_vel_vector,         format = '(a, 3g24.12)'
            print, 'odb_ephem_pos_vel_data_2_50        : ', record_3_struct.odb_ephem_pos_vel_data_2_50,        format = '(a, 3g24.12/, 97(37x, 3g24.12/))'
;            print, 'odb_ephem_rec3_spare1              : ', record_3_struct.odb_ephem_rec3_spare1,              format = '(a, 368i4.3)'
        endif
        return, record_3_struct
    end
    4: begin
        if keyword_set(print) then begin
            print, 'odb_ephem_sentinel                 : ', record_4_struct.odb_ephem_sentinel,                 format = '(a, 10d24.10)'
;            print, 'odb_ephem_rec4_spare1              : ', record_2_struct.odb_ephem_rec4_spare1,              format = '(a, 2720i4.3)'
        endif
        return, record_4_struct
    end
endcase
;
end
