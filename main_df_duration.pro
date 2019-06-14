pro main_df_duration
;; determine the DF duration mannually
thm_init
computer = 'I:'
@folders

;;;;;;;;; load the list
list_name = 'dfb_rbsp_subboth_list_good'
;list_name = 'dfb_rbsp_subboth_mageis_list_injection'
;list_name = 'dfb_rbsp_subboth_mageis_list_no_injection'

;;;;;;;;;;;;;;;;;;;;; record and save times ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; load events
events = load_list(list_name+'.txt', folder = list_folder)
;events = events[*,0:2] ;; diagnose

minutes_load_pre = 1.
minutes_load_aft = 3.

t0 = time_double(events[0,*])

times = dblarr(3, n_elements(events[0,*]))
;times = datain_simple(save_folder+'/times_'+list_name+'.dat', dim = 3, type = 'double') ;; repair for accidentally missed events
;;; plot magnetic field and record times.
for i = 0, n_elements(events[0,*])-1 do begin
	if times[0,i] eq 0 then begin
		;;; only plot for selected events
		sc = events[3, i]
		t_this = time_double(events[0,i])
		case sc of
		'r': probe_rb = 'a'
		's': probe_rb = 'b'
		endcase
		trange_load = [t_this-minutes_load_pre*60., t_this+minutes_load_aft*60.] ;;; for DFB
		rbsp_load, trange=trange_load, probe=sc, datatype = 'fgs', /tclip, rbsp_folder = rbsp_folder
		rbsp_load, trange=trange_load, probe=sc, datatype = 'fgl', /tclip, rbsp_folder = rbsp_folder
		split_vec, 'th'+sc+'_fgs_gsm_tclip'
		split_vec, 'th'+sc+'_fgl_gsm_tclip'
		tplot, ['th'+sc+'_fgs_gsm_tclip_z', 'th'+sc+'_fgl_gsm_tclip_z'], trange = trange_load
		timebar, t0[i], line = 1
		ctime, times_this ;; click three times: DF start, DF end, DFB end.
		timebar_mass, times_this
		times[*,i] = times_this
	endif
endfor
;;; manage times[0,*] regarding t0.
i_close = where((times[0,*]-t0 gt 0.) and (times[0,*]-t0 le 4.), n_close)
if n_close gt 0 then begin
	times[0,i_close] = t0[i_close]-0.01
endif

;;; save variable
dataout_simple, save_folder+'/times_'+list_name, times

;;;;;;;;;;;;;;;;;;;;;;; load times and compute durations, after running the first part ;;;;;;;;;;;;;;;;
;times = datain_simple(save_folder+'/times_'+list_name+'.dat', dim = 3, type = 'double')
;pos = datain_simple(save_folder+'/pos_'+list_name+'.dat', dim = 3, type = 'double')
;pos_eq = datain_simple(save_folder+'/pos_eq_'+list_name+'.dat', dim = 3, type = 'double')
;dur_df = times[1,*]-times[0,*]
;dur_dfb = times[2,*]-times[0,*]
;Lv = sqrt(pos_eq[0,*]^2+pos_eq[1,*]^2)
;
;;;;;;; binned quantity
;;qtt_name = 'x'
;;qtt_this = transpose(pos[0,*])
;;qtt_range = [-6, -3.]
;;qtt_range_plot = reverse(qtt_range)
;;binsize_this = 0.5
;;qtt_title_show = 'X [R!dE!n]'
;
;;qtt_name = 'xeq'
;;qtt_this = transpose(pos_eq[0,*])
;;qtt_range = [-8, -3.]
;;qtt_range_plot = reverse(qtt_range)
;;binsize_this = 0.8
;;qtt_title_show = 'X!deq!n [R!dE!n]'
;
;qtt_name = 'L'
;qtt_this = transpose(Lv)
;qtt_range = [3., 8.]
;qtt_range_plot = qtt_range
;binsize_this = 0.8
;qtt_title_show = 'L [R!dE!n]'
;
;;;;;;; value quantity
;
;qtt2_name = 'tdf'
;qtt2_this = transpose(dur_df)
;qtt_2_range = [0, 40]
;qtt_2_title_show = 'DF duration [s]'
;
;;qtt2_name = 'tdfb'
;;qtt2_this = transpose(dur_dfb)
;;qtt_2_range = [0, 200]
;;qtt_2_title_show = 'DFB duration [s]'
;
;;;;;; titles
;title = qtt2_name+' vs '+qtt_name
;savetitle = qtt2_name+'_vs_'+qtt_name
;
;;;; get values only
;;rstat, qtt2, qtt2_med, qtt2_lq, qtt2_uq
;
;;;; make plot
;stat_plot, qtt_this, qtt2_this, k_c = c_pts, bin_range = qtt_range, binsize = binsize_this, qtt_2_range = qtt_2_range, qtt_range = qtt_range_plot, qtt_2_title = qtt_2_title_show, qtt_title = qtt_title_show, kinbin = kinbin_all, bincntrs_out = bincntrs, vertical=vertical, qtt_tickname = qtt_ticknames, qtt_2_tickname = qtt_2_ticknames, bin_boundaries = bin_boundaries, title = title, avrg = avrg, std = std, med = med, /no_mean, color_med = 0, color_quar = 0, type_med = 'square', type_quar = 'ebar'
;;makepng, pic_folder+'/'+savetitle+method_suf+list_suf+dir_suf

stop
end
