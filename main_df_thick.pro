pro main_df_thick
;; compute the thickness of DFBs.
thm_init
computer = 'I:'
@folders

;;; choose type of velocity
v_use = 'efs'
normal_suf = '_minvar'
;normal_suf = '_binxbout'

;;;;;;;;; load the list and data ;;;
list_name_all = 'dfb_rbsp_subboth_list_good'
list_name_inj = 'dfb_rbsp_subboth_mageis_list_injection'
list_name_noinj = 'dfb_rbsp_subboth_mageis_list_no_injection'
events_all = load_list(list_name_all+'.txt', folder = list_folder)
events_inj = load_list(list_name_inj+'.txt', folder = list_folder)
events_noinj = load_list(list_name_noinj+'.txt', folder = list_folder)
nor = datain_simple(save_folder+'/'+list_name_all+'_normals'+normal_suf+'.dat', dim=3, type='double')
times = datain_simple(save_folder+'/times_'+list_name_all+'.dat', dim = 3, type = 'double')
df_ranges = times[0:1,*]

;;; for publication: revise the time of two events. The new thickvec variable uses these two values. The old one is called '_original'
;; injection event
df_ranges[*,16] = time_double(['2013-04-26/23:15:15', '2013-04-26/23:15:32'])
;; no-injection event
df_ranges[*,40] = time_double(['2013-06-02/00:06:01', '2013-06-02/00:06:30'])

;;; begin computing
dur_df = df_ranges[1,*]-df_ranges[0,*]
;;;;;;;;; find out the indices of the inj and no inj events.
;; injection
n_inj = n_elements(events_inj[0,*])
i_inj = intarr(n_inj)
for i = 0, n_inj-1 do begin
	i_match = where(strcmp(events_all[0,*], events_inj[0,i]), n_match)
	if n_match ne 1 then stop ;; problem
	i_inj[i] = i_match
endfor
;; no injection
n_noinj = n_elements(events_noinj[0,*])
i_noinj = intarr(n_noinj)
for i = 0, n_noinj-1 do begin
	i_match = where(strcmp(events_all[0,*], events_noinj[0,i]), n_match)
	if n_match ne 1 then stop ;; problem
	i_noinj[i] = i_match
endfor

;;;; diagnose
;events_all = events_all[*, 0:1]
;nor = nor[*, 0:1]
;df_ranges = df_ranges[*, 0:1]

;; first, make all normal directions pointing +X
i_neg_nx = where(nor[0,*] lt 0, n_neg_nx)
if n_neg_nx gt 0 then nor[*,i_neg_nx] = -nor[*,i_neg_nx]

;;;;;;;; begin computing thickness and other thins (slow)

;;;;; thickness (slow)
thick_km_vec = df_thick(events_all, normal_dir_in = nor, tranges = df_ranges, trange_style = 1, v_use = v_use, rbsp_folder = rbsp_folder, maxgap = 10, /vec)
dataout_simple, save_folder+'/'+list_name_all+'_'+v_use+'_thickvec', thick_km_vec

;;;; ion inertial length
;ni_list = event_status_instant(events_all, 'ni_rbsp', pre_time = 0, time_length = 2, datafolder=rbsp_folder)
;ni = ni_list[2,*]
;di = 227.27/sqrt(ni) ;; in km
;dataout_simple, save_folder+'/'+list_name_all+'_di', di

;;;; electron inertial length
;ne_list = event_status_instant(events_all, 'ne_rbsp', pre_time = 0, time_length = 2, datafolder=rbsp_folder)
;nele = ne_list[2,*]
;de = 5.31/sqrt(nele) ;; in km
;dataout_simple, save_folder+'/'+list_name_all+'_de', de

;;;; ion gyro radius
;b_list = event_status_instant(events_all, 'fgs_rbsp', pre_time = 0, time_length = 2, datafolder=rbsp_folder)
;;Tp_q_list = event_status_instant(events_this, 'Tp_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder)
;bttl = b_list[5,*]
;rhop = sqrt(2*mi*Tp_perp*e)/(e*bttl*1e-6) ;; in km, temperature must be in eV.
;dataout_simple, save_folder+'/'+list_name_all+'_gyrorp', rhop

;;;;;;;;;; load data
thick_km_vec = datain_simple(save_folder+'/'+list_name_all+'_'+v_use+'_thickvec.dat', dim=3, type='double')
thick_km = dotp_long(thick_km_vec, nor)
di = datain_simple(save_folder+'/'+list_name_all+'_di.dat', dim=1, type='double')
de = datain_simple(save_folder+'/'+list_name_all+'_de.dat', dim=1, type='double')
;rhop = datain_simple(save_folder+'/'+list_name_all+'_gyrorp.dat', dim=1, type='double')
thick_o_di = thick_km/di
thick_o_de = thick_km/de
;thick_o_rhop = thick_km/rhop

;;;;; print results
store_data, 'all', data = {i:indgen(n_elements(events_all[0,*]))}
store_data, 'inj', data = {i:i_inj}
store_data, 'noinj', data = {i:i_noinj}
groups = ['all', 'inj', 'noinj']
for i = 0, n_elements(groups)-1 do begin
	get_data, groups[i], data = data
	dur_this = dur_df[data.i]
	thick_km_this = thick_km[data.i]
	thick_o_di_this = thick_o_di[data.i]
	thick_o_de_this = thick_o_de[data.i]
;	thick_o_rhop_this = thick_rhop_di[data.i]
	i_earthward = where(thick_km_this gt 0, n_earthward)
	i_tailward = where(thick_km_this lt 0, n_tailward)
	rstat, abs(dur_this), med_dur, lq_dur, uq_dur
	rstat, abs(thick_km_this), med_thick, lq_thick, uq_thick
	rstat, abs(thick_o_di_this), med_thick_di, lq_thick_di, uq_thick_di
	rstat, abs(thick_o_de_this), med_thick_de, lq_thick_de, uq_thick_de
;	rstat, abs(thick_o_rhop_this), med_thick_rhop, lq_thick_rhop, uq_thick_rhop
	print, groups[i]+' events:'
	print, 'Earthward:'+strcompress(string(n_earthward))+' events, Tailward:'+strcompress(string(n_tailward))+' events.'
	print, 'DF duration (s):'+strcompress(string(lq_dur))+'/'+strcompress(string(med_dur))+'/'+strcompress(string(uq_dur))
	print, 'Thickness (km):'+strcompress(string(lq_thick))+'/'+strcompress(string(med_thick))+'/'+strcompress(string(uq_thick))
	print, 'Thickness (di):'+strcompress(string(lq_thick_di))+'/'+strcompress(string(med_thick_di))+'/'+strcompress(string(uq_thick_di))
	print, 'Thickness (de):'+strcompress(string(lq_thick_de))+'/'+strcompress(string(med_thick_de))+'/'+strcompress(string(uq_thick_de))
;	print, 'Thickness (rhop):'+strcompress(string(lq_thick_rhop))+'/'+strcompress(string(med_thick_rhop))+'/'+strcompress(string(uq_thick_rhop))
	print, ' '
endfor

;;; print the result for interested events
i_events_interest = [16, 40]
for i = 0, n_elements(i_events_interest)-1 do begin
	i_this = i_events_interest[i]
	print, 'Event:'+strcompress(string(i_this))
	print, 't0: '+events_all[0, i_this]
	print, 'DF range: '+time_string(df_ranges[0,i_this])+', '+time_string(df_ranges[1,i_this])
	print, 'Thickness (km):'+strcompress(string(thick_km[i_this]))
	print, 'Thickness (di):'+strcompress(string(thick_o_di[i_this]))
	print, 'Thickness (de):'+strcompress(string(thick_o_de[i_this]))
	print, ' '
endfor

stop
end
