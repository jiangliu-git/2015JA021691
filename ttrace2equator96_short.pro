pro ttrace2equator96_short, postv, newname = newname, plot_data = plot_data
;; postv: tplot variable storing the position in GSM, in the form of 'thx_pos*'; must be in RE.
;; output will be a tplot variable 'thx_efoot'
;; plot_data: if set, plot the input parameters

method = 'T96'
method_lc = 't96'
if keyword_set(newname) then outname = newname else outname = strmid(postv, 0, 3)+'_efoot'

get_data, postv, t, data
trange_load = [t[0], t[-1]]

;;;; Load OMNI solar wind data
del_data, 'OMNI*'
del_data, 'omni*'
timespan, trange_load[0], trange_load[1]-trange_load[0], /sec
omni_hro_load, trange = trange_load
tinterpol, 'OMNI_HRO_1min_BY_GSM', postv, newname = 'OMNI_HRO_1min_BY_GSM_tclip'
tinterpol, 'OMNI_HRO_1min_BZ_GSM', postv, newname = 'OMNI_HRO_1min_BZ_GSM_tclip'
tinterpol, 'OMNI_HRO_1min_proton_density', postv, newname = 'OMNI_HRO_1min_proton_density_tclip'
tinterpol, 'OMNI_HRO_1min_flow_speed', postv, newname = 'OMNI_HRO_1min_flow_speed_tclip'
store_data,'omni_imf',data=['OMNI_HRO_1min_BY_GSM_tclip','OMNI_HRO_1min_BZ_GSM_tclip']

;;;; load DST
del_data, 'kyoto_dst*'
kyoto_load_dst, trange = trange_load
tinterpol, 'kyoto_dst', postv, newname = 'kyoto_dst_tclip'

if keyword_set(plot_data) then begin
	tplot, [postv, 'kyoto_dst_tclip', 'omni_imf', 'OMNI_HRO_1min_proton_density_tclip', 'OMNI_HRO_1min_flow_speed_tclip']
	makepng, 'input_data'
endif

;;; make tsyganenko parameter
timespan, trange_load[0], trange_load[1]-trange_load[0], /sec
get_tsy_params, 'kyoto_dst_tclip', 'omni_imf', 'OMNI_HRO_1min_proton_density_tclip', 'OMNI_HRO_1min_flow_speed_tclip', method, /speed, /imf_yz, newname = method+'_par'
ttrace2equator, postv, newname=outname, external_model=method_lc, par=method+'_par', in_coord='gsm', out_coord='gsm'
end
