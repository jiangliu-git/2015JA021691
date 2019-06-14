pro main_plot_events_themis
;; plot an example of multi-point observation
thm_init
computer = 'I:'
;computer = '/home/jliu'
@folders

del_data, '*'
;; some constants for loading data
minutes_load = 2.5

;list_name = 'dfb_rbsp_list_original'
;list_name = 'dfb_rbsp_list_original2'
;list_name = 'dfb_rbsp_list_lead_tail'
list_name = 'dfb_rbsp_list_good'

;;; load events
events = load_list(list_name+'.txt', folder = list_folder)
;; diagnose
;events = events(*, [239, 295, 298, 300]) ;; for far events
;events = events(*, [78, 125, 235]) ;; for original 2
;events = events(*, 15)
;events = events(*, [2,9]) ;; typical no injec and have injec for examples
;events = events(*, 2) ;; no injec example
;events = events(*, 9) ;; have injec example

times = time_double(events(0,*))
probes = events(3,*)

;;; settings for plotting data
xsize = 6
ysize = 6
spec = 0 ;; 1 for spectrum, 2 for line plot

for i = 0, n_elements(events(0,*))-1 do begin
	;;;;;;;;; THEMIS ;;;;;;;;;;;
	;; get the position
	load_bin_data, probe = probes(i), trange = [times(i)-90., times(i)+90.], datatype='pos', /tclip, datafolder = pos_folder
	get_data, 'th'+probes(i)+'_state_pos_tclip', data = data
	x_this = mean(data.y(*,0), /nan)/RE
	y_this = mean(data.y(*,1), /nan)/RE
	z_this = mean(data.y(*,2), /nan)/RE
	trange_show = [times(i)-minutes_load*60., times(i)+minutes_load*60.] ;;; for DFB
	trange_load = [trange_show(0)-60., trange_show(1)+60.] ;;; for DFB
	;; B fgl
	;thm_load_esansst2, trange = trange_load, probe = probes(i)
	load_bin_data, trange = trange_load, probe = probes(i), /tclip, datatype = 'fgl', datafolder = fgl_folder 
	load_bin_data, trange = trange_load, probe = probes(i), /tclip, datatype = 'fgs', datafolder = fgs_folder 
	;;; ni
	load_bin_data, trange = trange_load, probe = probes(i), /tclip, datatype = 'ni', datafolder = ni_folder
	;; Pall
	load_bin_data, trange = trange_load, probe = probes(i), /tclip, datatype = 'Pall', datafolder = Pall_folder
	;; vi
	load_bin_data, trange = trange_load, probe = probes(i), /tclip, datatype = 'vi', datafolder = vi_folder
	;; viperp
	load_bin_data, trange = trange_load, probe = probes(i), /tclip, datatype = 'viperp', datafolder = viperp_folder
	
	;;; manage data for perticular events
	get_data, 'th'+probes(i)+'_fgs_gsm_tclip', data = data_fgs
	get_data, 'th'+probes(i)+'_fgl_gsm_tclip', data = data_fgl
	store_data, 'th'+probes(i)+'_fgs_gsm_tclip', data = {x:data_fgs.x, y:[[data_fgs.y(*,0)],[data_fgs.y(*,1)],[data_fgs.y(*,2)-100.]]}
	store_data, 'th'+probes(i)+'_fgl_gsm_tclip', data = {x:data_fgl.x, y:[[data_fgl.y(*,0)],[data_fgl.y(*,1)],[data_fgl.y(*,2)-100.]]}
	split_vec, 'th'+probes(i)+'_Pall_tclip' 
	ylim, 'th'+probes(i)+'_ptix_density_tclip', 1.01, 1.99
	;; mark variables
	get_data, 'th'+probes(i)+'_state_pos_tclip', t_pos, loc_pos
	store_data, 'th'+probes(i)+'_state_pos_RE_tclip', data = {x:t_pos, y:loc_pos/RE} 
	split_vec, 'th'+probes(i)+'_state_pos_RE_tclip'
	options, 'th'+probes(i)+'_state_pos_RE_tclip_x', ytitle = 'X!dGSM!n [R!dE!n]'
	options, 'th'+probes(i)+'_state_pos_RE_tclip_y', ytitle = 'Y!dGSM!n [R!dE!n]'
	options, 'th'+probes(i)+'_state_pos_RE_tclip_z', ytitle = 'Z!dGSM!n [R!dE!n]'
	options, 'th?_fg?_gsm_tclip', colors = [2,4,6], ytitle = 'B!dGSM!n', ysubtitle = '!c[nT]', labels = ['B!dx!n', 'B!dy!n', 'B!dz!n-100nT'], labflag = 1
	options, 'th?_ptix_density_tclip', ytitle = 'n!di!n', ysubtitle = '!c[cm!U-3!n]'
	options, 'th?_ptix_velocity_gsm_tclip', colors = [2,4,6], ytitle = 'V!di!n', ysubtitle = '!c[km/s]', labels = ['V!dx!n', 'V!dy!n', 'V!dz!n'], labflag = 1
	options, 'th?_ptix_vperp_gsm_tclip', colors = [2,4,6], ytitle = 'V!di!n perp', ysubtitle = '!c[km/s]', labels = ['V!dx!n', 'V!dy!n', 'V!dz!n'], labflag = 1
	options, 'th'+probes(i)+'_ptix_en_eflux', ytitle = 'Ion Eflux', ysubtitle = '!c[eV]'
	options, 'th'+probes(i)+'_ptex_en_eflux', ytitle = 'Electron Eflux', ysubtitle = '!c[eV]'
	options, 'th?_Pall_tclip', ytitle = 'P', ysubtitle = '!c[nPa]', colors = [2,4,0], labels = ['P!db!n', 'P!dth!n', 'P!dttl!n'], labflag = 1;, ylog = 1
	options, 'th?_Pall_tclip_y', ytitle = 'P!dth', ysubtitle = '!c[nPa]';, ylog = 1
	options, '*', thick = 2.4
	
	popen, pic_folder+'/events/event_'+strcompress(string(i), /remove)
	print_options,xsize=xsize, ysize=ysize ;; use this for single plot
	;tplot, ['th'+probes(i)+'_fgl_gsm_tclip', 'th'+probes(i)+'_ptix_density_tclip', 'th'+probes(i)+'_Pall_tclip', 'th'+probes(i)+'_ptix_vperp_gsm_tclip'], trange = trange_show, title = strcompress(string(i), /remove)+' th'+probes(i)+' '+time_string(times(i))
	;tplot, ['th'+probes(i)+'_fgl_gsm_tclip', 'th'+probes(i)+'_ptix_density_tclip', 'th'+probes(i)+'_Pall_tclip_y', 'th'+probes(i)+'_ptix_vperp_gsm_tclip', 'th'+probes(i)+'_ptix_en_eflux', 'th'+probes(i)+'_ptex_en_eflux'], trange = trange_show, title = 'A DFB inside VAP apogee', var_label = ['th'+probes(i)+'_state_pos_RE_tclip_z', 'th'+probes(i)+'_state_pos_RE_tclip_y', 'th'+probes(i)+'_state_pos_RE_tclip_x']
	tplot, ['th'+probes(i)+'_fgl_gsm_tclip', 'th'+probes(i)+'_ptix_density_tclip', 'th'+probes(i)+'_Pall_tclip_y', 'th'+probes(i)+'_ptix_vperp_gsm_tclip'], trange = trange_show, title = 'A DFB inside VAP apogee', var_label = ['th'+probes(i)+'_state_pos_RE_tclip_z', 'th'+probes(i)+'_state_pos_RE_tclip_y', 'th'+probes(i)+'_state_pos_RE_tclip_x']
	xyouts, 0.2, 0.6, 'R: '+strcompress(sqrt(x_this^2+y_this^2+z_this^2), /remove)+'!crho: '+strcompress(sqrt(x_this^2+y_this^2), /remove)+'!cX: '+strcompress(x_this, /remove)+'!cY: '+strcompress(y_this, /remove)+'!cZ: '+strcompress(z_this, /remove), /normal
	timebar_mass, 0, varname=['th'+probes(i)+'_fgl_gsm_tclip', 'th'+probes(i)+'_ptix_vperp_gsm_tclip'], /databar, line = 3
;	xyouts, [0.2, 0.2, 0,2, 0.2], [0.8, 0.6, 0.4, 0.2], ['(a)', '(b)', '(c)', '(d)'], charsize = 2, /normal
		pclose
	;	makepng, pic_folder+'/events_temp/event_'+strcompress(string(i), /remove)
	endelse
endfor ;; for of i, element on multi_list
end
