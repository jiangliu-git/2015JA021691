pro main_superpose
;;; superpose quantities 
thm_init
computer = 'I:'
;computer = '/home/jliu'
@folders

;; superpose range before and after
minutes_show = 2.5

;; whethether to save a png in the pics folder
save_png = 0
;save_png = 1

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

;; the type of detrend for the list
;list_dtr = 'model' ;; using model
;list_dtr = '10' ;; using 10-min average
list_dtr = 'both' ;; using 10-min average

;; whehter to fill spectrum
fill_suf = '' ;; no fill
;fill_suf = '_fill' ;; fill


;; seperately
;classes = '_good' ;; all
classes = ['_injection', '_no_injection']
;classes = '_no_injection'

;;; cannot work for superpose, disable
;case list_dtr of
;'model': detrend_model = 'T96'
;else: detrend_model = ''
;endcase
detrend_model = ''

case fill_suf of
'': fill = 0
'_fill': fill = 1
endcase

;;;; for publication
tv_names = ['fgs_gsm_z_superpose_quartiles', 'fgs_gsm_z_detrend_superpose_quartiles', 'fgs_gsm_ttl_superpose_quartiles', 'fgs_gsm_ttl_detrend_superpose_quartiles', 'ion_density_superpose_quartiles', 'pspec_avgtemp_superpose_quartiles', 'espec_avgtemp_superpose_quartiles', 'all_Pth_superpose_quartiles', 'all_Pall_z_superpose_quartiles', 'mageis_pspec_superpose_median', 'mageis_espec_superpose_median', 'efw_esvy_mgse_vxb_removed_coro_removed_spinfit_ttl_superpose_quartiles', 'efw_vperp_gsm_ttl_superpose_quartiles']

;;; for test
;tv_names = 'hope_sa_ion_density_superpose_quartiles'
;tv_names = 'hope_sa_Pth_superpose_quartiles'
;tv_names = 'hope_sa_pspec_Pth_superpose_quartiles'

for i = 0, n_elements(classes)-1 do begin
	del_data, '*'
	if ~strcmp(classes[i], '_good') then listsuf = species_suf+judge_suf else listsuf = ''
	events_this = load_list('dfb_rbsp_sub'+list_dtr+listsuf+'_list'+classes[i]+'.txt', folder = list_folder)

	;;;;;;;; Bz and Bttl
	;b_q_list = event_status_instant(events_this, 'fgs_rbsp', pre_time = 2.5, time_length = 1, detrend_model = detrend_model, datafolder=rbsp_folder)
	;bzttl_dtr = b_q_list[4:5, *]
	;superpose_data_fast, 'fgs_rbsp', components='z', /total, t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=bzttl_dtr
	;copy_data, 'fgs_gsm_z_superpose_quartiles', 'fgs_gsm_z_detrend_superpose_quartiles'
	;copy_data, 'fgs_gsm_ttl_superpose_quartiles', 'fgs_gsm_ttl_detrend_superpose_quartiles'
	;del_data, 'fgs_gsm_z_superpose_quartiles'
	;del_data, 'fgs_gsm_ttl_superpose_quartiles'
	;superpose_data_fast, 'fgs_rbsp', components='z', /total, t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder

	;;;;; nefw
	;nefw_q_list = event_status_instant(events_this, 'efw_density', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder)
	;nefw_dtr = nefw_q_list[2,*]
	;superpose_data_fast, 'efw_density', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=nefw_dtr

	;;;; ni
	;n_q_list = event_status_instant(events_this, 'ni_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder)
	;n_dtr = n_q_list[2,*]
	;superpose_data_fast, 'ni_rbsp', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=n_dtr

	;;;;; np, hope only ;;;;;
	;nphope_q_list = event_status_instant(events_this, 'np_hope_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder, energy_max = 10000)
	;nphope_dtr = nphope_q_list[2,*]
	;superpose_data_fast, 'np_hope_rbsp', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=nphope_dtr, energy_max = 10000

	;;;;; ni, hope only ;;;;;
	;nihope_q_list = event_status_instant(events_this, 'ni_hope_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder, energy_max = 10000)
	;nihope_dtr = nihope_q_list[2,*]
	;superpose_data_fast, 'ni_hope_rbsp', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=nihope_dtr, energy_max = 10000

	;;;; Tp
	;Tp_q_list = event_status_instant(events_this, 'Tp_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder)
	;Tp_dtr = Tp_q_list[2,*]
	;superpose_data_fast, 'Tp_rbsp', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=Tp_dtr
	;;;; Te
	;Te_q_list = event_status_instant(events_this, 'Te_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder)
	;Te_dtr = Te_q_list[2,*]
	;superpose_data_fast, 'Te_rbsp', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=Te_dtr

	;;;; Pp, hope only
	;Pp_hope_q_list = event_status_instant(events_this, 'Pp_hope_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder, energy_max = 10000)
	;Pp_hope_dtr = Pp_hope_q_list[2,*]
	;superpose_data_fast, 'Pp_hope_rbsp', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=Pp_hope_dtr, energy_max = 10000

	;;;; Pth
	;Pth_q_list = event_status_instant(events_this, 'Pth_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder)
	;Pth_dtr = Pth_q_list[2,*]
	;superpose_data_fast, 'Pth_rbsp', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=Pth_dtr

	;;;; Pth, hope only
	;Pth_hope_q_list = event_status_instant(events_this, 'Pth_hope_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder, energy_max = 10000)
	;Pth_hope_dtr = Pth_hope_q_list[2,*]
	;superpose_data_fast, 'Pth_hope_rbsp', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=Pth_hope_dtr, energy_max = 10000

	;;;; Pttl
	;Pall_q_list = event_status_instant(events_this, 'Pall_rbsp', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder, fill = fill)
	;Pall_dtr = Pall_q_list[4,*]
	;superpose_data_fast, 'Pall_rbsp', components='z', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=Pall_dtr, fill = fill

	;;;;; spectra
	;mageisp_q_list = event_status_instant(events_this, 'mageis_p', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder, fill = fill)
	;mageisp_q = mageisp_q_list[2:*,*]
	;superpose_data_fast, 'mageis_p', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, normalize_v=mageisp_q
	;mageise_q_list = event_status_instant(events_this, 'mageis_e', pre_time = 2.5, time_length = 1, datafolder=rbsp_folder, fill = fill)
	;mageise_q = mageise_q_list[2:*,*]
	;superpose_data_fast, 'mageis_e', t0p_list=[events_this[0, *], events_this[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, normalize_v=mageise_q

	;;;;; electric field, quantity is called 'efw_esvy_mgse_vxb_removed_coro_removed_spinfit_'+['x', 'y', 'z', 'ttl']+'_superpose_quartiles'
	;superpose_data_fast, 'efs_rbsp', components=['x', 'y', 'z'], t0p_list=[events_this[0,*], events_this[3,*]], /total, pre = 3., after = 3.

	;;;;; perpendicular velocity computed from electric field
	superpose_data_fast, 'vperp_efs_rbsp', /total, t0p_list=[events_this[0,*], events_this[3,*]], pre = 3., after = 3.

	;;;;; save data
	for j = 0, n_elements(tv_names)-1 do begin
		if tv_exist(tv_names[j]) then tplot_save, tv_names[j], filename = save_folder+'/'+tv_names[j]+classes[i]
	endfor
	tplot, tv_names, trange = [time_double('0 1 1')-minutes_show*60., time_double('0 1 1')+minutes_show*60.], title = classes[i]
	timebar, '0 1 1', line = 1
	if save_png then makepng, pic_folder+'/superpose'+classes[i]
endfor ;; for of i, classes

end
