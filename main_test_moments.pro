pro main_test_moments
thm_init
computer = 'I:'
;computer = '/home/jliu'
@folders

del_data, '*'


;;;;;;;;;; test rbsp data ;;;;;;;;;;;;;;
;;;; some constants for loading data
minutes_load = 4
spec = 1

;energy_min = 0. ;; turn off
energy_min = 200. ;; eV

list_name = 'dfb_rbsp_submodel_list_good'

events = load_list(list_name+'.txt', folder = list_folder)
event = events(*, 9) ;; have injec example

time = time_double(event(0))
sc = event(3)
trange_load = [time-minutes_load*60., time+minutes_load*60.]

rbsp_load, trange=trange_load, probe=sc, datatype = 'fgs', /tclip, rbsp_folder = rbsp_folder
rbsp_load, trange=trange_load, probe=sc, datatype = 'mageis', /tclip, rbsp_folder = rbsp_folder, level = 2
rbsp_load, trange=trange_load, probe=sc, datatype = 'hope_sa', /tclip, rbsp_folder = rbsp_folder, level = 2, reduce_connect = 'algebra'

combine_spec, 'th'+sc+'_mageis_pspec_tclip', 'th'+sc+'_hope_sa_pspec_tclip', newname = 'th'+sc+'_pspec_combined_tclip', /eV2keV_2nd
combine_spec, 'th'+sc+'_mageis_espec_tclip', 'th'+sc+'_hope_sa_espec_tclip', newname = 'th'+sc+'_espec_combined_tclip', /eV2keV_2nd
stop

;; label the variables
options,'th?_mageis_pspec_tclip', ylog = 1, zlog = 1, ytitle = 'Proton flux', ysubtitle = '[keV]', ztitle = '[cm!u-2!ns!u-1!nsr!u-1!nkeV!u-1!n]', spec = spec, labels = pspec_mageis_labels 
options,'th?_mageis_espec_tclip', ylog = 1, zlog = 1, ytitle = 'Electron flux', ysubtitle = '[keV]', ztitle = '[cm!u-2!ns!u-1!nsr!u-1!nkeV!u-1!n]', spec = spec, labels = espec_mageis_labels 
options,'th?_hope_sa_pspec_tclip', ylog = 1, zlog = 1, ytitle = 'Proton flux', ysubtitle = '[eV]', ztitle = '[cm!u-2!ns!u-1!nsr!u-1!nkeV!u-1!n]', spec = spec, labels = pspec_hope_labels 
options,'th?_hope_sa_espec_tclip', ylog = 1, zlog = 1, ytitle = 'Electron flux', ysubtitle = '[eV]', ztitle = '[cm!u-2!ns!u-1!nsr!u-1!nkeV!u-1!n]', spec = spec, labels = espec_hope_labels 
options,'th?_hope_sa_ospec_tclip', ylog = 1, zlog = 1, ytitle = 'Oxygen flux', ysubtitle = '[eV]', ztitle = '[cm!u-2!ns!u-1!nsr!u-1!nkeV!u-1!n]', spec = spec, labels = pspec_hope_labels 
options,'th?_hope_sa_hespec_tclip', ylog = 1, zlog = 1, ytitle = 'Helium flux', ysubtitle = '[eV]', ztitle = '[cm!u-2!ns!u-1!nsr!u-1!nkeV!u-1!n]', spec = spec, labels = pspec_hope_labels 
options,'th?_pspec_combined_tclip', ylog = 1, zlog = 1, ytitle = 'Proton flux', ysubtitle = '[keV]', ztitle = '[cm!u-2!ns!u-1!nsr!u-1!nkeV!u-1!n]', spec = spec, labels = pspec_hope_labels 
options,'th?_espec_combined_tclip', ylog = 1, zlog = 1, ytitle = 'Electron flux', ysubtitle = '[keV]', ztitle = '[cm!u-2!ns!u-1!nsr!u-1!nkeV!u-1!n]', spec = spec, labels = pspec_hope_labels 

;; label positions
get_data, 'th'+sc+'_state_pos_tclip', t_pos, loc_pos
store_data, 'th'+sc+'_state_pos_RE_tclip', data = {x:t_pos, y:loc_pos/RE} 
store_data, 'th'+sc+'_state_pos_RE_tclip_rho', data = {x:t_pos, y:sqrt(total((loc_pos/RE)^2, 2))} 
;; get L* values
ttrace2equator, 'th'+sc+'_state_pos_RE_tclip', newname='th'+sc+'_efoot',external_model='t89',par=2.0D,in_coord='gsm',out_coord='gsm'
get_data, 'th'+sc+'_efoot', t_efoot, efoot
store_data, 'th'+sc+'_Lstar', data = {x:t_efoot, y:sqrt(total(efoot[*,0:1]^2,2))}

split_vec, 'th'+sc+'_state_pos_RE_tclip'
options, 'th'+sc+'_state_pos_RE_tclip_x', ytitle = sc+'X!dGSM!n [R!dE!n]'
options, 'th'+sc+'_state_pos_RE_tclip_y', ytitle = sc+'Y!dGSM!n [R!dE!n]'
options, 'th'+sc+'_state_pos_RE_tclip_z', ytitle = sc+'Z!dGSM!n [R!dE!n]'
options, 'th'+sc+'_state_pos_RE_tclip_rho', ytitle = sc+rho_letter+'!dGSM!n [R!dE!n]'
options, 'th'+sc+'_Lstar', ytitle = sc+'L!u*!n [R!dE!n]'

;;; proton
;compute_moments, 'th'+sc+'_pspec_combined_tclip', intype = 'flux', inunits_energy = 'keV', inunits_flux = 'keV', energy_min = energy_min, particle_types = 'p', /fill
;tplot, ['th'+sc+'_pspec_combined_tclip', 'th'+sc+'_pspec_combined_tclip_density', 'th'+sc+'_pspec_combined_tclip_avgtemp', 'th'+sc+'_pspec_combined_tclip_pth'], var_label = ['th'+sc+'_state_pos_RE_tclip_z', 'th'+sc+'_state_pos_RE_tclip_y', 'th'+sc+'_state_pos_RE_tclip_x', 'th'+sc+'_Lstar']
;get_data, 'th'+sc+'_pspec_combined_tclip', t, data, energy

;check_range = ['2013 4 26 23 15 15', '2013 4 26 23 16']
;i_check = where((t gt time_double(check_range[0])) and (t gt time_double(check_range[1])))
;time_clip, 'th'+sc+'_pspec_combined_tclip', check_range[0], check_range[1]
;options, 'th'+sc+'_pspec_combined_tclip_tclip', spec = 1, ylog = 1, zlog = 1
;tplot, 'th'+sc+'_pspec_combined_tclip_tclip'
;print, 'Flux:'
;print, reform(data[i_check[0], *])
;print, 'Energy:'
;print, reform(energy[i_check[0], *])

;;; helium
;tv_name = 'th'+sc+'_hope_sa_hespec_tclip'
;compute_moments, tv_name, intype = 'flux', inunits_energy = 'eV', inunits_flux = 'keV', energy_min = energy_min, particle_types = 'He+'
;tplot, tv_name+['', '_density', '_avgtemp', '_pth'], var_label = ['th'+sc+'_state_pos_RE_tclip_z', 'th'+sc+'_state_pos_RE_tclip_y', 'th'+sc+'_state_pos_RE_tclip_x', 'th'+sc+'_Lstar']

;;; Oxygen
;tv_name = 'th'+sc+'_hope_sa_ospec_tclip'
;compute_moments, tv_name, intype = 'flux', inunits_energy = 'eV', inunits_flux = 'keV', energy_min = energy_min, particle_types = 'O+'
;tplot, tv_name+['', '_density', '_avgtemp', '_pth'], var_label = ['th'+sc+'_state_pos_RE_tclip_z', 'th'+sc+'_state_pos_RE_tclip_y', 'th'+sc+'_state_pos_RE_tclip_x', 'th'+sc+'_Lstar']

;;; all ions
compute_moments, 'th'+sc+['_pspec_combined_tclip', '_espec_combined_tclip', '_hope_sa_hespec_tclip', '_hope_sa_ospec_tclip'], intypes = 'flux', inunits_energy = ['keV', 'keV', 'eV', 'eV'], inunits_flux = 'keV', energy_min = energy_min, particle_types = ['p', 'e', 'He+', 'O+'], /combine
tplot, ['th'+sc+'_pspec_combined_tclip', 'th'+sc+'_espec_combined_tclip', 'th'+sc+'_hope_sa_hespec_tclip', 'th'+sc+'_hope_sa_ospec_tclip', 'th'+sc+'_density', 'th'+sc+'_avgtemp', 'th'+sc+'_pth'], var_label = ['th'+sc+'_state_pos_RE_tclip_z', 'th'+sc+'_state_pos_RE_tclip_y', 'th'+sc+'_state_pos_RE_tclip_x', 'th'+sc+'_Lstar']
;;tplot, ['th'+sc+'_pspec_combined_tclip_pth', 'th'+sc+'_espec_combined_tclip_pth', 'th'+sc+'_hope_sa_hespec_tclip_pth', 'th'+sc+'_hope_sa_ospec_tclip_pth', 'th'+sc+'_pth'], var_label = ['th'+sc+'_state_pos_RE_tclip_z', 'th'+sc+'_state_pos_RE_tclip_y', 'th'+sc+'_state_pos_RE_tclip_x', 'th'+sc+'_Lstar']

;;; electrons
;compute_moments, 'th'+sc+'_espec_combined_tclip', intype = 'flux', inunits_energy = 'keV', inunits_flux = 'keV', energy_min = energy_min, particle_types = 'e'
;tplot, ['th'+sc+'_espec_combined_tclip', 'th'+sc+'_espec_combined_tclip_density', 'th'+sc+'_espec_combined_tclip_avgtemp', 'th'+sc+'_espec_combined_tclip_pth'], var_label = ['th'+sc+'_state_pos_RE_tclip_z', 'th'+sc+'_state_pos_RE_tclip_y', 'th'+sc+'_state_pos_RE_tclip_x', 'th'+sc+'_Lstar']

;;;;;;;;;; test THEMIS data ;;;;;;;;;;;;;;;;;;
;sc = 'a'
;trange = ['13 7 23 8', '13 7 23 8 20']
;
;thm_load_state,probe=sc, datatype = 'peer', /get_supp, trange=trange
;thm_load_esa_pkt,probe=sc, trange=trange
;thm_part_moments, probe = sc, instrum = 'peer', $
;trange=trange, tplotnames = tn, $
;verbose = 2;, /bgnd_remove
;
;get_data, 'th'+sc+'_peer_en_eflux', t, eflux, energy
;flux = eflux/energy
;flux = flux*1000. ;; eV to keV
;energy = energy/1000. ;; eV to keV
;store_data, 'th'+sc+'_peer_en_eflux_new', data={x:t, y:eflux, v:energy}
;options, 'th'+sc+'_peer_en_eflux_new', ysubtitle = '[keV]', ylog=1, spec=1, zlog=1, ztitle = 'eV/cm^2-sec-sr-eV'
;store_data, 'th'+sc+'_peer_en_flux', data={x:t, y:flux, v:energy}
;options, 'th'+sc+'_peer_en_flux', ysubtitle = '[keV]', ylog=1, spec=1, zlog=1, ztitle = '1/cm^2-sec-sr-keV'
;
;
;;tv_compute = 'th'+sc+'_peer_en_eflux'
;;compute_moments, tv_compute, intype = 'eflux', inunits_energy = 'eV', inunits_flux = 'eV', particle_types = 'e'
;
;;tv_compute = 'th'+sc+'_peer_en_eflux_new'
;;compute_moments, tv_compute, intype = 'eflux', inunits_energy = 'keV', inunits_flux = 'keV', particle_types = 'e'
;
;tv_compute = 'th'+sc+'_peer_en_flux'
;compute_moments, tv_compute, intype = 'flux', inunits_energy = 'keV', inunits_flux = 'keV', particle_types = 'e'
;
;tplot, ['th'+sc+'_peer_en_eflux', tv_compute, 'th'+sc+'_peer_density', tv_compute+'_density', 'th'+sc+'_peer_avgtemp', tv_compute+'_avgtemp', tv_compute+'_pth']

stop
end
