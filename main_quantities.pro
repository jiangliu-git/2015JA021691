pro main_quantities
computer = 'I:'
@folders
;;;;;; find the typical value of quantities

;;;;;;;;; load the list
;list_name = 'dfb_rbsp_subboth_list_good'
list_name = 'dfb_rbsp_subboth_mageis_list_injection'
;list_name = 'dfb_rbsp_subboth_mageis_list_no_injection'
;;; load events
events = load_list(list_name+'.txt', folder = list_folder)

;;;;;;;;; find the values
;;; the type of data to find

;;;; kyoto Dst
;qtttype = 'kyoto_dst'
;qttfolder = dst_folder

;;;;; kyoto AL
qtttype = 'kyoto_al'
qttfolder = al_folder

if strcmp(qtttype, 'kyoto_dst') then begin
	time_exact = events[0,*]
	time_length = 4*60
endif else begin
	time_exact = 0
	time_length = 3
endelse

qtt_list = event_status_instant(events, qtttype, time_length=time_length, time_exact = time_exact, datafolder=qttfolder)
case 1 of 
strmatch(qtttype, 'fg*'): qtt = qtt_list[4,*] ;; 3d field, Bz only
else: qtt = qtt_list[2,*] ;; 1d data
endcase

;; get the typical values of the quantities
rstat, qtt, qtt_med, qtt_lq, qtt_hq
print, qtttype+':'
print, qtt_lq
print, qtt_med
print, qtt_hq

stop
end
