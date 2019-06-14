pro main_seperate_efield
;;; separate different groups to check there e field.
thm_init
computer = 'I:'
;computer = '/home/jliu'
@folders

;;;; criteria for injection or no injection
n_channels = 3
crit_inj = 3.
crit_noinj_all = 2.
;crit_noinj_channels = 1.5
crit_noinj_channels = 100 ;; disable
consecutive = 0 ;; whether require consecutive bins (tested to be not matter for species_suf of '' (either))
inf_good = 0 ;; whether count infinite ratio good or not

del_data, '*'
;; some constants for loading data
minutes_load = 2.5

;; ways to tell injection, ions, electrons, or either
;species_suf = '_p'
;species_suf = '_e'
species_suf = '' ;; either

;; whether to use mageis only or both mageis and ect (for electron only)
;judge_suf = '' ;; both for electron
judge_suf = '_mageis' ;; mageis only

;; whether to detrend the spectra before judging
detrend_suf = ''
;detrend_suf = '_detrend'

;; the time interval for computing the average E.
;interval_suf = '' ; 1 min
interval_suf = '_30s' ; 30 secs


;; whether to exclude DEH from no injection events
;deh = 0 ;; original
deh = 1 ;; new regarding Sergeev's comment, will reduce the number of no-injection events by one. The event is [2013-06-20/02:01:01 ths]. Even for this event, the only point going below 2 is after/before = 0.45 for 31 keV channel.

;; seconds before and after event to tell whether dispersed or dispersionless. comment to use default
;secs_injtype = 180.
;crit_dispersion = 60.

;; the type of detrend for the list
;list_dtr = 'model' ;; using model
;list_dtr = '10' ;; using 10-min average
list_dtr = 'both' ;; using both model and 10-min average

list_name = 'dfb_rbsp_sub'+list_dtr+'_list_good'

;;; load events
events = load_list(list_name+'.txt', folder = list_folder)
;; diagnose
;events = events[*, 11:12]

;;;; events to omit
;i_omit = [66,71,13,20,25,60,70] ;; numbers for the "both" list. 66,67: inside plasmasphere; 13,20: 3 min within plasmapause crossing; 25,60,70: plasmapause crossing

;;; arrays to grow
ind_inj = [-1]
ind_noinj = [-1]
ind_unclear = [-1]

alltype_p = ['']
alltype_e = ['']

;; record the injection type
inj_type = replicate('none', n_elements(events[0,*]))
pe_type = replicate('', 3, n_elements(events[0,*])) ;; |p|e|overall| Y for injection, N for no injection, ? for unclear

for i = 0, n_elements(events[0,*])-1 do begin
	;; omit events
	if keyword_set(i_omit) then begin
		if total(i eq i_omit) gt 0 then begin
			continue
		endif
	endif

	sc = events[3,i]
	time = time_double(events[0, i])
	case sc of
	'r': probe_rb = 'a'
	's': probe_rb = 'b'
	endcase
	del_data, 'th'+sc+'_mageis_espec_tclip'
	del_data, 'th'+sc+'_hope_sa_espec_tclip'
	del_data, 'th'+sc+'_mageis_pspec_tclip'
	del_data, 'th'+sc+'_hope_sa_pspec_tclip'
	rbsp_load, trange=[time-5*60., time+5*60.], probe=sc, datatype = 'mageis', /tclip, rbsp_folder = rbsp_folder, level = 2
	rbsp_load, trange=[time-5*60., time+5*60.], probe=sc, datatype = 'hope_sa', /tclip, rbsp_folder = rbsp_folder, level = 2, reduce_connect = 'algebra'
	;;; combine the electron spectrum
	combine_spec, 'th'+sc+'_mageis_espec_tclip', 'th'+sc+'_hope_sa_espec_tclip', newname = 'th'+sc+'_ect_espec_tclip', /interpol2more, /eV2keV_2nd

	;;;;;; decide whether this is a injection or not
	;;; proton, use mageis only because hope has many bad bins
	inj_p = injection_decide('th'+sc+'_mageis_pspec_tclip', t0 = time, consecutive = consecutive, n_channels = n_channels, crit_inj = crit_inj, crit_noinj_all = crit_noinj_all, crit_noinj_channels = crit_noinj_channels, type = type_p, secs_injtype = secs_injtype, crit_dispersion = crit_dispersion, inf_good = inf_good)
	alltype_p = [alltype_p, type_p]
	;;; electron, mageis only
	if strcmp(judge_suf, '_mageis') then e_judge_var = 'th'+sc+'_mageis_espec_tclip'
	if strcmp(judge_suf, '') then e_judge_var = 'th'+sc+'_ect_espec_tclip'
	inj_e = injection_decide(e_judge_var, t0 = time, consecutive = consecutive, n_channels = n_channels, crit_inj = crit_inj, crit_noinj_all = crit_noinj_all, crit_noinj_channels = crit_noinj_channels, type = type_e, secs_injtype = secs_injtype, crit_dispersion = crit_dispersion, inf_good = inf_good, deh = deh)
	alltype_e = [alltype_e, type_e]
	;; criteria
	if strcmp(species_suf, '') then begin
		tell_inj = (inj_p eq 1) or (inj_e eq 1)
		tell_noinj = (inj_p eq 0) and (inj_e eq 0)
	endif
	if strcmp(species_suf, '_p') then begin
		tell_inj = inj_p eq 1
		tell_noinj = inj_p eq 0
	endif
	if strcmp(species_suf, '_e') then begin
		tell_inj = inj_e eq 1
		tell_noinj = inj_e eq 0
	endif

	;; mark the pe_type record
	case inj_p of
	1: pe_type[0,i] = 'Y'
	0: pe_type[0,i] = 'N'
	else: pe_type[0,i] = '?'
	endcase
	case inj_e of
	1: pe_type[1,i] = 'Y'
	0: pe_type[1,i] = 'N'
	else: pe_type[1,i] = '?'
	endcase

	;; injection
	if tell_inj then begin
		pe_type[2,i] = 'Y'
		ind_inj = [ind_inj, i]
		;;; mark injection types (proton or electron) for usage of other programs
		if (inj_p eq 1) and (inj_e eq 1) then inj_type[i] = 'both' else begin
			if inj_p eq 1 then begin
				if inj_e eq 0 then inj_type[i] = 'pYeN' else inj_type[i] = 'pYeU'
			endif
			if inj_e eq 1 then begin
				if inj_p eq 0 then inj_type[i] = 'pNeY' else inj_type[i] = 'pUeY'
			endif
		endelse
	endif else begin
		;; no injection
		if tell_noinj then begin
			pe_type[2,i] = 'N'
			ind_noinj = [ind_noinj, i]
		endif else begin
			pe_type[2,i] = '?'
			ind_unclear = [ind_unclear, i]
		endelse
	endelse
endfor ;; for of i, element on multi_list

print, 'Numer of injection: '+string(n_elements(ind_inj)-1)
print, 'Numer of no-injection: '+string(n_elements(ind_noinj)-1)
;stop

store_data, 'injection', data = ind_inj
store_data, 'no_injection', data = ind_noinj
store_data, 'unclear', data = ind_unclear

;;; count the injection types
alltype_p = alltype_p[1:*]
alltype_e = alltype_e[1:*]
i_dispersionless_p = where(strcmp(alltype_p, 'dispersionless'), n_dispersionless_p)
i_dispersed_p = where(strcmp(alltype_p, 'dispersed'), n_dispersed_p)
i_invdispersed_p = where(strcmp(alltype_p, 'inverse-dispersed'), n_invdispersed_p)
i_unclear_p = where(strcmp(alltype_p, 'unclear'), n_unclear_p)
i_dispersionless_e = where(strcmp(alltype_e, 'dispersionless'), n_dispersionless_e)
i_dispersed_e = where(strcmp(alltype_e, 'dispersed'), n_dispersed_e)
i_invdispersed_e = where(strcmp(alltype_e, 'inverse-dispersed'), n_invdispersed_e)
i_unclear_e = where(strcmp(alltype_e, 'unclear'), n_unclear_e)
;; print results
if strcmp_or(species_suf, ['', '_p']) then print, '- Proton: dispersionless:'+strcompress(string(n_dispersionless_p))+' dispersed:'+strcompress(string(n_dispersed_p))+' inverse-dispersed:'+strcompress(string(n_invdispersed_p))+' unclear:'+strcompress(string(n_unclear_p))
if n_dispersed_p gt 0 then begin
	print, '-- dispersed events:'
	print, events[*, i_dispersed_p]
endif
if strcmp_or(species_suf, ['', '_e']) then print, '- Electron: dispersionless:'+strcompress(string(n_dispersionless_e))+' dispersed:'+strcompress(string(n_dispersed_e))+' inverse-dispersed:'+strcompress(string(n_invdispersed_e))+' unclear:'+strcompress(string(n_unclear_e))
if n_dispersed_e gt 0 then begin
	print, '-- dispersed events:'
	print, events[*, i_dispersed_e]
endif

stop

;;;;;; mark injection types (proton or electron) for usage of other programs
output_txt, transpose(inj_type), filename = save_folder+'/'+list_name+'_injpe.txt'
;output_txt, pe_type, filename = save_folder+'/'+list_name+species_suf+judge_suf+'_petype.txt'

;stop

classes = ['injection', 'no_injection']
;classes = 'no_injection'

;;;;;;;;;;;;;;;;; examine the electric field of different types of events
components = ['Ex', 'Ey', 'Ez', '|E|']

;;; determine the interval to compute
case interval_suf of
'_30s': begin
	pre_time = -0.25
	time_length = 0.5
	end
else: begin
	pre_time = -0.5
	time_length = 1.
	end
endcase

OPENW, 1, 'e_values_sub'+list_dtr+species_suf+judge_suf+detrend_suf+interval_suf+'.txt' ;; file to write results
for i = 0, n_elements(classes)-1 do begin
	get_data, classes[i], data = ind_this
	if n_elements(ind_this) gt 1 then begin
		ind_this = ind_this[1:*]
		events_this = events[*,ind_this]
		;;; store the event lists
		output_txt, events_this, filename = list_folder+'/dfb_rbsp_sub'+list_dtr+species_suf+judge_suf+'_list_'+classes[i]+'.txt'

		;;; typical electric field values
		if strcmp(detrend_suf, '_detrend') then begin
			e_q_list = event_status_instant(events_this, 'efs_rbsp', pre_time = 2.5, time_length = 1, /major_only)
			e_q = e_q_list[2:4,*]
		endif else e_q = 0
		e_ave_list = event_status_instant(events_this, 'efs_rbsp', pre_time = pre_time, time_length = time_length, /major_only, detrend_v = e_q)
		e_ave = e_ave_list[2:5,*]
		e_peak_list = event_status_instant(events_this, 'efs_rbsp', pre_time = pre_time, time_length = time_length, /major_only, /peak, detrend_v = e_q)
		e_peak = e_peak_list[2:5,*]
		i_have = where(finite(e_ave[3,*]), n_have)

		;;; quantity to judge whether electric field is contaminated
		vsvy_peak_list = event_status_instant(events_this, 'vsvy_rbsp', pre_time = pre_time, time_length = time_length, /major_only, /peak)
		vsvy_peak = vsvy_peak_list[2:5,*]
		vsvy_peakpeak = max(abs(vsvy_peak), /absolute)
		i_bad = where(vsvy_peakpeak gt 190, n_bad)
		if n_bad gt 0 then begin
			e_ave[i_bad] = !values.f_nan
			e_peak[i_bad] = !values.f_nan
		endif

		;;; change of magnetic field
		b_q_list = event_status_instant(events_this, 'fgs_rbsp', pre_time = 2, time_length = 2, /major_only, datafolder = rbsp_folder) ;; range same as injection_decide
		b_peak_list = event_status_instant(events_this, 'fgs_rbsp', pre_time = pre_time, time_length = time_length, /major_only, datafolder = rbsp_folder, /peak)
		b_ratios = b_peak_list[5,*]/b_q_list[5,*]

		;;; write the values to a file
		printf, 1, classes[i]+' events:'+strcompress(string(n_elements(ind_this)))
		printf, 1, strcompress(string(n_have))+' events have electric field.'
		printf, 1, strcompress(string(n_bad))+' events have contaminated electric field.'
		printf, 1, '- Quartiles Average:'
		for j = 0, 3 do begin
			rstat, abs(e_ave[j,*]), med_e_ave, lq_e_ave, uq_e_ave
			printf, 1, '--'+components[j]+':'+strcompress(string([lq_e_ave, med_e_ave, uq_e_ave]))
		endfor
		printf, 1, '- Quartiles Peak:'
		for j = 0, 3 do begin
			rstat, abs(e_peak[j,*]), med_e_peak, lq_e_peak, uq_e_peak
			printf, 1, '--'+components[j]+':'+strcompress(string([lq_e_peak, med_e_peak, uq_e_peak]))
		endfor
		printf, 1, '- Quartiles Change of |B| (peak over quiet average):'
		rstat, abs(b_ratios), med_b_ratio, lq_b_ratio, uq_b_ratio
		printf, 1, strcompress(string([lq_b_ratio, med_b_ratio, uq_b_ratio]))

		;;;;;;;;;;;; record strange events ;;;;;;;;;;;;;;;;;;;;
		if strcmp(classes[i], 'injection') then begin
			;;;;; write the number of dispersed and dispersionless injections
			if strcmp_or(species_suf, ['', '_p']) then printf, 1, '- Proton: dispersionless:'+strcompress(string(n_dispersionless_p))+' dispersed:'+strcompress(string(n_dispersed_p))+' inversely-dispersed:'+strcompress(string(n_invdispersed_p))+' unclear:'+strcompress(string(n_unclear_p))
			if n_dispersed_p gt 0 then begin
				printf, 1, '-- dispersed events:'
				printf, 1, events[*, i_dispersed_p]
			endif
			if strcmp_or(species_suf, ['', '_e']) then printf, 1, '- Electron: dispersionless:'+strcompress(string(n_dispersionless_e))+' dispersed:'+strcompress(string(n_dispersed_e))+' inversely-dispersed:'+strcompress(string(n_invdispersed_e))+' unclear:'+strcompress(string(n_unclear_e))
			if n_dispersed_p gt 0 then begin
				printf, 1, '-- dispersed events:'
				printf, 1, events[*, i_dispersed_e]
			endif
			;;;;; store the vanishing E, have injection event list
			i_strange = where((e_ave[3,*] lt 2.) or (abs(e_peak[3,*]) lt 3.), n_strange)
			if n_strange gt 0 then begin
				events_strange = events_this[*,i_strange]
				output_txt, events_strange, filename = list_folder+'/dfb_rbsp_sub'+list_dtr+species_suf+'_list_smallEinj'+interval_suf+'.txt'
				b_ratios_strange = b_ratios[i_strange]
				printf, 1, '- Quartiles |B| ratio, vanishing E, have injection:'
				rstat, abs(b_ratios_strange), med_b_ratio_strange, lq_b_ratio_strange, uq_b_ratio_strange
				printf, 1, strcompress(string([lq_b_ratio_strange, med_b_ratio_strange, uq_b_ratio_strange]))
			endif
		endif

		;;; store the large E, no injection event list
		if strcmp(classes[i], 'no_injection') then begin
			i_strange = where((e_ave[3,*] gt 2.5) or (abs(e_peak[3,*]) gt 6.), n_strange)
			if n_strange gt 0 then begin
				events_strange = events_this[*,i_strange]
				output_txt, events_strange, filename = list_folder+'/dfb_rbsp_sub'+list_dtr+species_suf+'_list_bigEnoinj'+interval_suf+'.txt'
				b_ratios_strange = b_ratios[i_strange]
				printf, 1, '- Quartiles |B| ratio, large E, no injection:'
				rstat, abs(b_ratios_strange), med_b_ratio_strange, lq_b_ratio_strange, uq_b_ratio_strange
				printf, 1, strcompress(string([lq_b_ratio_strange, med_b_ratio_strange, uq_b_ratio_strange]))
			endif
		endif
		printf, 1, '/n'

		;;;; superpose the E profiles
		;superpose_data_fast, 'efs_rbsp', components=['x', 'y', 'z'], t0p_list=[events_this[0,*], events_this[3,*]], /total, pre = 3., after = 3., detrend_v = e_q
		;options, 'efw_esvy_mgse_vxb_removed_coro_removed_spinfit_*', colors = [0,0,0]
		;tplot, 'efw_esvy_mgse_vxb_removed_coro_removed_spinfit_'+['x', 'y', 'z', 'ttl']+'_superpose_quartiles', title = classes[i], trange = ['1999 12 31 23 57', '2000 1 1 0 3']
		;makepng, pic_folder+'/e_superpose_'+classes[i]+'_sub'+list_dtr+judge_suf+detrend_suf
	endif else begin
		print, 'No '+classes[i]+' events !'
	endelse
endfor
CLOSE, 1

stop
end
