pro main_inj_stat
;;; statistics about injection
thm_init
computer = 'I:'
;computer = '/home/jliu'
@folders

;; the type of detrend for the list
;list_dtr = 'model' ;; using model
;list_dtr = '10' ;; using 10-min average
list_dtr = 'both' ;; using both model and 10-min average

;;;; criteria for injection channel (times) must be the same as main_seperate_efield.pro
crit_inj = 3.

;;;; symbol used for plot
usersym, 1.*[-1,0,1,0], 1.*[0,1,0,-1], /fill, thick = 1;; diamond

list_name = 'dfb_rbsp_sub'+list_dtr+'_list_good'

;;; load events
events = load_list(list_name+'.txt', folder = list_folder)
;;; load injection type list (proton, electron, or both, can also tell whether injection). This file is generated by main_seperate_efield.pro
inj_type = read_txt(save_folder+'/'+list_name+'_injpe.txt')

i_both = where(strcmp(inj_type, 'both'), n_both)
i_p_all = where(strcmp(inj_type, 'both') or strmatch(inj_type, 'pYe?'), n_p_all)
i_e_all = where(strcmp(inj_type, 'both') or strmatch(inj_type, 'p?eY'), n_e_all)
i_p = where(strmatch(inj_type, 'pYe?'), n_p)
i_e = where(strmatch(inj_type, 'p?eY'), n_e)
i_pYeN = where(strmatch(inj_type, 'pYeN'), n_pYeN)
i_pNeY = where(strmatch(inj_type, 'pNeY'), n_pNeY)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; the p only vs e only regarding DF normal ;;;;;;;;;;;;;;
;;;; compute normal direction
;method_suf = '_minvar'
method_suf = '_binxbout'
case method_suf of 
	'_minvar': begin
		method_num = 1
		tranges_in = 0 ;; automatic for minvar
	end
	'_binxbout': begin
		method_num = 2
		times = datain_simple(save_folder+'/times_'+list_name+'.dat', dim = 3, type = 'double')
		tranges_in = times[0:1,*] ;; use manually defined ranges.
	end
endcase
nor = df_normal(events, method = method_num, datatype = 'fgl_rbsp', bfolder = rbsp_folder, tranges_in = tranges_in, c_mn = 3)
;print, median(nor[1,i_both], /even)
;print, median(nor[1,i_p], /even)
;print, median(nor[1,i_e], /even)
;;; print the normal directions
;print, nor, format = '(3f6.2)'
;output_txt, nor, filename = save_folder+'/'+list_name+'_normals.txt', format = '(3f6.2)'
dataout_simple, save_folder+'/'+list_name+'_normals'+method_suf, nor

stop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; find the maximum energy that shows the injection signature ;;;;
zlog = 1 ;; the scale for the increase ratio
inf_good = 0 ;; whether count infinity as good or not
big_size = 1.0
mid_size = 0.55
small_size = 0.25

plot_rept = 1 ;; 1 or 0
plot_hope = 0 ;; 1 or 0, cannot use this yet, due to bad hope channels

;; legend locations
y_leg_start = 0.48 ; ratio of axis
y_leg_end = 0.68 ; ratio of axis
leg_char = 0.7 ;; size

;;; plot parameters
n_p_horiz = 1
n_p_vert = 2
left_margin = 0.15
right_margin = 0.15
top_margin = 0.05
bot_margin = 0.07
space_vert = 0.01
size_x = 4.5
size_y = 7
titles = ['Injection flux enhancements', '']
etitle = '|E|' ;; choose horizontal axis here
y_abc = [6e3, 13]
abc = ['(a) Proton', '(b) Electron']

positions = panel_positions([n_p_horiz, n_p_vert], lr_margins = [left_margin, right_margin], bt_margins = [bot_margin, top_margin], space = [0, space_vert])

;;; electric field
;; make
;e_ave_list = event_status_instant(events, 'efs_rbsp', pre_time = -0.5, time_length = 1, /major_only)
;e_ave = e_ave_list[2:5,*]
;dataout_simple, save_folder+'/e_ave', e_ave
;e_peak_list = event_status_instant(events, 'efs_rbsp', pre_time = -0.5, time_length = 1, /major_only, /peak)
;e_peak = e_peak_list[2:5,*]
;dataout_simple, save_folder+'/e_peak', e_peak

;; load
e_ave = datain_simple(save_folder+'/e_ave'+'.dat', dim=4, type='double')
e_peak = datain_simple(save_folder+'/e_peak'+'.dat', dim=4, type='double')

e_use = e_ave
etitle = l_angle+etitle+r_angle
xrange = [0., 14.5]
x_leg_start = 11. ; mV/m
x_leg_end = 13. ; mV/m

;e_use = e_peak
;etitle = 'Peak '+etitle
;xrange = [0., 44.5]
;x_leg_start = 30. ; mV/m
;x_leg_end = 40. ; mV/m

;;; mageis number of channels
no_use = check_datatype('mageis_p', dim = dim_p)
no_use = check_datatype('mageis_e', dim = dim_e)
no_use = check_datatype('rept_p', dim = dim_p_rept)
no_use = check_datatype('rept_e', dim = dim_e_rept)
no_use = check_datatype('hope_sa_p', dim = dim_p_hope)
no_use = check_datatype('hope_sa_e', dim = dim_e_hope)

;;; proton
store_data, 'proton', data = {i:i_p_all, dim_mageis:dim_p, dim_rept:dim_p_rept, dim_hope:dim_p_hope, tv_suf:'p'}
store_data, 'electron', data = {i:i_e_all, dim_mageis:dim_e, dim_rept:dim_e_rept, dim_hope:dim_e_hope, tv_suf:'e'}

species = ['proton', 'electron']
popen, pic_folder+'/channel_ratios'
print_options,xsize=size_x,ysize=size_y
for i_species = 0, n_elements(species)-1 do begin
	;;;;;; plot specifics
	if i_species eq 0 then begin
		xtitle = ''
		xticknames = replicate(' ', 50)
	endif else begin
		xtitle = etitle+' [mV/m]'
		xticknames = ''
	endelse
	;;;;;; record values
	get_data, species[i_species], data = this
	n_events = n_elements(this.i)
	max_inj_energy_all = dblarr(n_events)
	dim_this = this.dim_mageis
	if plot_rept then dim_this = dim_this+this.dim_rept
	if plot_hope then dim_this = dim_this+this.dim_hope
	ratios_all = dblarr(dim_this, n_events)
	energies_all = dblarr(dim_this, n_events)
	for i = 0, n_events-1 do begin
		time = time_double(events[0, this.i[i]])
		sc = events[3, this.i[i]]
		par_this = this.tv_suf[0]
		del_data, 'th'+sc+'_mageis_'+par_this+'spec*'
		;;; mageis
		rbsp_load, trange=[time-5*60., time+5*60.], probe=sc, datatype = 'mageis', /tclip, rbsp_folder = rbsp_folder, level = 2
		no_use = injection_decide('th'+sc+'_mageis_'+par_this+'spec_tclip', t0 = time, crit_inj = crit_inj, type = type_mageis, inj_energy_all = inj_energy_all_mageis, ratios = ratios, inf_good = inf_good)
		get_data, 'th'+sc+'_mageis_'+par_this+'spec_tclip', t_nouse, d_nouse, energies_mageis
		;;; rept
		if plot_rept then begin
			rbsp_load, trange=[time-5*60., time+5*60.], probe=sc, datatype = 'rept', /tclip, rbsp_folder = rbsp_folder, level = 2
			no_use = injection_decide('th'+sc+'_rept_'+par_this+'spec_tclip', t0 = time, crit_inj = crit_inj, type = type_rept, inj_energy_all = inj_energy_all_rept, ratios = ratios_rept, inf_good = inf_good)
			get_data, 'th'+sc+'_rept_'+par_this+'spec_tclip', t_nouse, d_nouse, energies_rept
			energies_rept = energies_rept*1000. ;; MeV to keV
			;;; remove overlap with mageis
			i_overlap = where(energies_rept lt max(energies_mageis, /nan), n_overlap)
			if n_overlap gt 0 then begin
				energies_rept[i_overlap] = !values.f_nan
			endif
		endif
		;;; hope
		if plot_hope then begin
			rbsp_load, trange=[time-5*60., time+5*60.], probe=sc, datatype = 'hope_sa', /tclip, rbsp_folder = rbsp_folder, level = 2
			no_use = injection_decide('th'+sc+'_hope_sa_'+par_this+'spec_tclip', t0 = time, crit_inj = crit_inj, type = type_hope, inj_energy_all = inj_energy_all_hope, ratios = ratios_hope, inf_good = inf_good)
			get_data, 'th'+sc+'_hope_sa_'+par_this+'spec_tclip', t_nouse, d_nouse, energies_hope
			energies_hope = energies_hope/1000. ;; eV to keV
			;;; remove overlap with mageis
			i_overlap = where(energies_hope gt min(energies_mageis, /nan), n_overlap)
			if n_overlap gt 0 then begin
				energies_hope[i_overlap] = !values.f_nan
			endif
		endif

		;;; energies
		if plot_hope then begin
			energies_all[0:this.dim_hope-1,i] = transpose(energies_hope[0,*])
			energies_all[this.dim_hope:this.dim_hope+this.dim_mageis-1,i] = transpose(energies_mageis[0,*])
			ratios_all[0:this.dim_hope-1,i] = ratios_hope
			ratios_all[this.dim_hope:this.dim_hope+this.dim_mageis-1,i] = ratios
			dim_start_rept = this.dim_hope+this.dim_mageis
		endif else begin
			energies_all[0:this.dim_mageis-1,i] = transpose(energies_mageis[0,*])
			ratios_all[0:this.dim_mageis-1,i] = ratios
			dim_start_rept = this.dim_mageis
		endelse
		if plot_rept then begin
			energies_all[dim_start_rept:*,i] = transpose(energies_rept[0,*])
			ratios_all[dim_start_rept:*,i] = ratios_rept
		endif
		;; max energy
		if keyword_set(inj_energy_all_rept) then max_inj_energy = max([[inj_energy_all_mageis], [inj_energy_all_rept]], /nan) else max_inj_energy = max(inj_energy_all_mageis, /nan)
		max_inj_energy_all[i] = max_inj_energy
	endfor
	;;;;;; manage Electric field
	efield = e_use[*,this.i]
	emag = efield[3,*]
	;;; choose horizontal axis
	;; E strength as horizontal axis
	if strmatch(etitle, '*|E|*') then ehoriz = emag
	;;;;;;; make plot
	;;; energy range
	;max_energy_plot = max(max_inj_energy_all, /nan)
	max_energy_plot = max(energies_all, /nan)
	n_channels = n_elements(energies_all[*,0])
	min_energy = min(energies_all, /nan)
	;;; ratio range
	i_bad_ratio = where(ratios_all le 0, n_bad_ratio)
	if n_bad_ratio gt 0 then ratios_all[i_bad_ratio] = !values.f_nan
	max_ratio = max(ratios_all, /nan)
	min_ratio = min(ratios_all, /nan)
	;;; make plot
	plot, ehoriz, ehoriz, xrange = xrange, xstyle = 1, xtitle = xtitle, yrange = [0.3*min_energy, 2*max_energy_plot],  ystyle = 1, ytitle = 'Energy [keV]', /nodata, ylog = 1, xmargin = [10, 10], title = titles[i_species], /noerase, position = positions[*,i_species], xtickname = xticknames
	for i = 0, n_events-1 do begin
		ratios_this = ratios_all[*,i]
		colors_this = fltarr(n_channels)
		sizes_this = fltarr(n_channels)
		for j = 0, n_channels-1 do begin
			energies = energies_all[*, i]
			if ratios_this[j] gt crit_inj then symsize = big_size else begin
				if ratios_this[j] ge 1. then symsize = mid_size else symsize = small_size
			endelse
			if inf_good then if_good = finite(ratios_this[j], /nan) else if_good = finite(ratios_this[j])
			sizes_this[j] = symsize
			;;;; determine the color based on the ratio
			if zlog then begin
				;; log scale
				color_this = 7+(254-7)/(alog(max_ratio)-alog(min_ratio))*(alog(ratios_this[j])-alog(min_ratio))
			endif else begin
				;; linear
				color_this = 7+(254-7)/(max_ratio-min_ratio)*(ratios_this[j]-min_ratio) ;; linear
			endelse
			colors_this[j] = color_this
			if if_good then oplot, [ehoriz[i], !values.f_nan], [energies[j], !values.f_nan], psym = 8, color = color_this, symsize = symsize
		endfor
;		if ehoriz[i] lt 2 then stop
	endfor
	draw_color_scale, range = [min_ratio, max_ratio], brange = [7, 254], title = 'Increase ratio', log = zlog
	;; draw legend
	if i_species eq 0 then begin
		;; draw box
		y_leg_start_value = 10^(!y.crange[0]+y_leg_start*(!y.crange[1]-!y.crange[0]))
		y_leg_end_value = 10^(!y.crange[0]+y_leg_end*(!y.crange[1]-!y.crange[0]))
		oplot, [x_leg_start, x_leg_end, x_leg_end, x_leg_start, x_leg_start], [y_leg_start_value, y_leg_start_value, y_leg_end_value, y_leg_end_value, y_leg_start_value]
		;; draw legend
		x_leg = x_leg_start+0.2*(x_leg_end-x_leg_start)
		x_str = x_leg_start+0.7*(x_leg_end-x_leg_start)
		down_str = 0.91
		x_title = x_leg_start+0.5*(x_leg_end-x_leg_start)
		y_leg0 = y_leg_start_value*(y_leg_end_value/y_leg_start_value)^0.8
		y_leg1 = y_leg_start_value*(y_leg_end_value/y_leg_start_value)^0.2
		y_leg2 = y_leg_start_value*(y_leg_end_value/y_leg_start_value)^0.4
		y_leg3 = y_leg_start_value*(y_leg_end_value/y_leg_start_value)^0.6
		oplot, [x_leg, !values.f_nan], [y_leg1, !values.f_nan], psym = 8, symsize = big_size
		oplot, [x_leg, !values.f_nan], [y_leg2, !values.f_nan], psym = 8, symsize = mid_size
		oplot, [x_leg, !values.f_nan], [y_leg3, !values.f_nan], psym = 8, symsize = small_size
		xyouts, x_title, y_leg0, 'Ratios', charsize = leg_char, alignment = 0.5
		xyouts, x_str, y_leg1*down_str, '>3', charsize = leg_char, alignment = 0.5
		xyouts, x_str, y_leg2*down_str, '1'+minus_sign+'3', charsize = leg_char, alignment = 0.5
		xyouts, x_str, y_leg3*down_str, '<1', charsize = leg_char, alignment = 0.5
	endif
	;; draw abc
	xyouts, 0.7, y_abc[i_species], abc[i_species], /data
;	makepng, pic_folder+'/evse_'+species[i_species]
;	stop
endfor
pclose

stop
end
