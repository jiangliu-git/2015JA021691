pro main_superpose_plot
;;; plot results from main_superpose
thm_init
computer = 'I:'
;computer = '/home/jliu'
@folders

;;;;;;;; plot specifics
;;; 11 panels
abc = [['a', 'c', 'e', 'g', 'i', 'k', 'm', 'o', 'q', 's', 'u', 'w'], ['b', 'd', 'f', 'h', 'j', 'l', 'n', 'p', 'r', 't', 'v', 'x']]
y_abc = [0.952, 0.882, 0.81, 0.727, 0.65, 0.57, 0.49, 0.415, 0.338, 0.26, 0.18, 0.104]

size_x = 6.6
x_abc = replicate(0.19, n_elements(abc[*,0]))

;; superpose range before and after
minutes_show = 2.5

tv_names = ['fgs_gsm_z_detrend_superpose_quartiles', 'fgs_gsm_ttl_detrend_superpose_quartiles', 'ion_density_superpose_quartiles', 'pspec_avgtemp_superpose_quartiles', 'espec_avgtemp_superpose_quartiles', 'all_Pth_superpose_quartiles', 'all_Pall_z_superpose_quartiles', 'mageis_pspec_superpose_median', 'mageis_espec_superpose_median']
if n_elements(y_abc) gt 9 then begin
	tv_names = ['fgs_gsm_z_superpose_quartiles', tv_names]
	size_y = 13.
endif
if n_elements(y_abc) gt 10 then begin
	tv_names = [tv_names, 'efw_esvy_mgse_vxb_removed_coro_removed_spinfit_ttl_superpose_quartiles']
	size_y = 13.
endif
if n_elements(y_abc) gt 11 then begin
	tv_names = [tv_names, 'efw_vperp_gsm_ttl_superpose_quartiles']
	size_y = 14.5
endif
n_plot = n_elements(tv_names)
tv_names_plot = strarr(n_plot)

classes = ['injection', 'no_injection']
titles = ['Injection', 'No injection']

for i = 0, n_elements(classes)-1 do begin
	del_data, '*'
	events_this = load_list(list_folder+'/dfb_rbsp_subboth_mageis_list_'+classes[i]+'.txt', folder = list_folder)
	;;;; save data
	for j = 0, n_elements(tv_names)-1 do begin
		tplot_restore, filename = save_folder+'/'+tv_names[j]+'_'+classes[i]+'.tplot'
		if ~strmatch(tv_names[j], '*mageis_?spec*') then begin
			split_vec, tv_names[j]
			store_data, tv_names[j]+'_black', data = [tv_names[j]+'_x', tv_names[j]+'_y', tv_names[j]+'_z']
			options, tv_names[j]+'_x', colors = 0, linestyle = 2
  			options, tv_names[j]+'_y', colors = 0
  			options, tv_names[j]+'_z', colors = 0, linestyle = 2
			tv_names_plot[j] = tv_names[j]+'_black'
		endif else tv_names_plot[j] = tv_names[j]
	endfor
	;;;; plot data
	;;; uncomment below to have only left side ytitles.
;	if i eq 0 then begin
		options, 'fgs_gsm_z_superpose_quartiles_black', ytitle = 'B!dz!n', ysubtitle = '!c[nT]'
		options, 'fgs_gsm_z_detrend_superpose_quartiles_black', ytitle = delta_letter+'B!dz!n', ysubtitle = '!c[nT]'
		options, 'fgs_gsm_ttl_detrend_superpose_quartiles_black', ytitle = delta_letter+'|B|', ysubtitle = '!c[nT]'
		options, 'ion_density_superpose_quartiles_black', ytitle = delta_letter+'n!di!n', ysubtitle = '!c[cm!u-3!n]'
		options, 'all_Pth_superpose_quartiles_black', ytitle = delta_letter+'P!dth!n', ysubtitle = '!c[nPa]'
		options, 'all_Pall_z_superpose_quartiles_black', ytitle = delta_letter+'P!dttl!n', ysubtitle = '!c[nPa]'
		options, 'pspec_avgtemp_superpose_quartiles_black', ytitle = delta_letter+'T!dp', ysubtitle = '!c[eV]'
		options, 'espec_avgtemp_superpose_quartiles_black', ytitle = delta_letter+'T!de', ysubtitle = '!c[eV]'
		options, 'mageis_pspec_superpose_median', ytitle = 'p!u+!n energy', ysubtitle = '!c[keV]'
		options, 'mageis_espec_superpose_median', ytitle = 'e!u'+minus_sign+'!n energy', ysubtitle = '!c[keV]'
		options, 'efw_esvy_mgse_vxb_removed_coro_removed_spinfit_ttl_superpose_quartiles_black', ytitle = '|E|', ysubtitle = '!c[mV/m]'
		options, 'efw_vperp_gsm_ttl_superpose_quartiles_black', ytitle = '|V!dE'+cross+'B!n|', ysubtitle = '!c[km/s]'
;	endif else begin
;		options, '*superpose_*', ytitle = '', ysubtitle = ''
;	endelse
	options, 'mageis_pspec_superpose_median', spec = 1, ylog = 1, zlog = 1
	options, 'mageis_espec_superpose_median', spec = 1, ylog = 1, zlog = 1
	ylim, 'mageis_pspec_superpose_median', 60., 1000.
	ylim, 'mageis_espec_superpose_median', 30., 4000.
	zlim, 'mageis_pspec_superpose_median', 0.6, 10.
	zlim, 'mageis_espec_superpose_median', 0.6, 11.

	;;; limit the temperatures
	ylim, 'pspec_avgtemp_superpose_quartiles_black', -4.99e3, 1.99e4
	ylim, 'espec_avgtemp_superpose_quartiles_black', -699., 2499.

	;;; limit electric field
	ylim, 'efw_esvy_mgse_vxb_removed_coro_removed_spinfit_ttl_superpose_quartiles_black', 0.001, 11.999
	ylim, 'efw_vperp_gsm_ttl_superpose_quartiles_black', 0.001, 59.999

	options, '*superpose_*', xtickname=['-2','0','2'], thick=l_thick
	tplot_options,'vtitle',''

	popen, pic_folder+'/superpose_'+classes[i]
	print_options,xsize=size_x,ysize=size_y
	tplot, tv_names_plot, trange = [time_double('0 1 1')-minutes_show*60., time_double('0 1 1')+minutes_show*60.], title = titles[i]
	timebar, '0 1 1', line = 1
	timebar_mass, 0, /databar, varname = ['fgs_gsm_z_detrend_superpose_quartiles', 'fgs_gsm_ttl_detrend_superpose_quartiles', 'ion_density_superpose_quartiles', 'pspec_avgtemp_superpose_quartiles', 'espec_avgtemp_superpose_quartiles', 'all_Pth_superpose_quartiles', 'all_Pall_z_superpose_quartiles']+'_black', line = 3
	;; print abc
	case n_elements(y_abc) of
	9: begin
		xyouts, x_abc[0:-2], y_abc[0:-2], '('+abc[0:-2,i]+')', /normal
		xyouts, x_abc[-2:-1], y_abc[-2:-1], '('+abc[-2:-1,i]+')', /normal, color = 255
		end
	11: begin
		xyouts, x_abc[0:-4], y_abc[0:-4], '('+abc[0:-4,i]+')', /normal
		xyouts, x_abc[-1], y_abc[-1], '('+abc[-1,i]+')', /normal
		xyouts, x_abc[-3:-2], y_abc[-3:-2], '('+abc[-3:-2,i]+')', /normal, color = 255
		end
	12: begin
		xyouts, x_abc[0:-5], y_abc[0:-5], '('+abc[0:-5,i]+')', /normal
		xyouts, x_abc[-2:-1], y_abc[-2:-1], '('+abc[-2:-1,i]+')', /normal
		xyouts, x_abc[-4:-3], y_abc[-4:-3], '('+abc[-4:-3,i]+')', /normal, color = 255
		end
	endcase
	;; x lable
	xyouts, 0.5, 0.02, 'Minutes to t!d0!n', /normal, align = 0.5
	;; z lable
	;;; original values
	case n_plot of
	9: xyouts, 0.925, 0.16, 'Flux increased ratio', /normal, orientation = 90, align = 0.5
	10: xyouts, 0.925, 0.19, 'Flux increased ratio', /normal, orientation = 90, align = 0.5
	11: xyouts, 0.925, 0.22, 'Flux increased ratio', /normal, orientation = 90, align = 0.5
	12: xyouts, 0.925, 0.25, 'Flux increased ratio', /normal, orientation = 90, align = 0.5
	endcase
	pclose
endfor ;; for of i, classes
end
