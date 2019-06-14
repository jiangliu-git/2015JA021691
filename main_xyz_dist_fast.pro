pro main_xyz_dist_fast
thm_init
;; generate bin plots, like occurence rates at different locations, should be faster than main_rhophiz_dist.
;; this is for dists in which the satellite orbit time is needed
computer='I:'
;computer='/home/jliu'

@folders

;project = 'no'
project = 'yes'

list_name = 'dfb_rbsp_subboth_list_good'

season1 = ['2012 11 1','2013 11 1']
;season1 = ['2012 9 15','2014 4 30']
;; test
;season1 = ['2013 3 24','2014 4 30']
seasons = season1

probes = ['r','s']

;split = 40 ;; split each season to shares
split = 500 ;; split each season to shares
n_pos_temp = 10 ;; minutes of data to compute t96 values

;; get the sc positions of the events
events = load_list(list_name+'.txt', folder = list_folder)
n_events = n_elements(events[0,*])
pos_list = event_status_instant(events, 'pos', time_length =3, datafolder=rbsp_folder, /major_only)
pos_list[2:*,*] = pos_list[2:*,*]/RE ; ...|x|y|z|
;;; save data
dataout_simple, save_folder+'/pos_'+list_name, pos_list[2:4,*]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; dist, not normalized ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x_dfb = pos_list[2,*]
y_dfb = pos_list[3,*]
z_dfb = pos_list[4,*]
rho_dfb = sqrt(x_dfb^2+y_dfb^2)
phi_dfb = atan2(y_dfb, x_dfb, /degrees, /full_circle)
data_nouse = dblarr(n_elements(x_dfb))

;; set examination range and bin size (based on loaded values)
rhorange = [3.4, 5.8] ;;
phirange = [90., 270.] ;; in degrees
;zrange = [min(z_dfb), max(z_dfb)]
zrange = [-100, 100.]


;;; decide limit and binsize the same time, by how many bins you want, this make sure bincenters always the preset ranges.
n_bin_rho = 4
binsizerho = (rhorange(1)-rhorange(0))/n_bin_rho

n_bin_phi = 10
binsizephi = (phirange(1)-phirange(0))/n_bin_phi

; r-phi dist
bin2d, rho_dfb, phi_dfb, data_nouse, xrange = rhorange, yrange = phirange, binsize = [binsizerho, binsizephi], binhistogram = counts_dfb_rhophi, xcenters = rhocenters, ycenters = phicenters
print, 'Total number of events:'
print, total(counts_dfb_rhophi)

;;; store data for the use of MAIN_XYZ_DIST_PLOT
;;;; not normalized
store_data, 'pos_rhophi', data={rho:rhocenters, phi:phicenters, n:counts_dfb_rhophi}
tplot_save, 'pos_rhophi', filename = save_folder+'/pos_rhophi'

;;;;;;; position in equatorial plane
if strcmp(project, 'yes') then begin
	pos_eq_list = dblarr(5, n_events)
	for i = 0, n_events-1 do begin
		pos_eq_list[0,i] = i
		pos_eq_list[1,i] = pos_eq_list[1,i]
	
		sc_this = events[3,i]
		ts_this = linspace(pos_list[1,i]-fix(n_pos_temp/2)*60., pos_list[1,i]+fix(n_pos_temp/2)*60., n_pos_temp, type = 'double')
		pos_this = rebin(transpose(pos_list[2:4,i]), n_pos_temp, 3)
		store_data, 'th'+sc_this+'_pos_temp', data = {x:ts_this, y:pos_this}
		ttrace2equator96, 'th'+sc_this+'_pos_temp', newname = 'th'+sc_this+'_efoot_dfb', imf_folder = imf_folder, vsw_folder = vsw_folder, nisw_folder = nisw_folder, dst_folder = dst_folder
		get_data, 'th'+sc_this+'_efoot_dfb', t_eq_dfb, data_eq_dfb
		pos_eq_list[2:4, i] = mean(data_eq_dfb, dim = 1, /nan)
	endfor
	;;; save data
	;dataout_simple, save_folder+'/pos_eq_'+list_name, pos_eq_list[2:4,*]

	;;;; dist, not normalized
	x_eq_dfb = pos_eq_list[2,*]
	y_eq_dfb = pos_eq_list[3,*]
	rho_eq_dfb = sqrt(x_eq_dfb^2+y_eq_dfb^2)
	phi_eq_dfb = atan2(y_eq_dfb, x_eq_dfb, /degrees, /full_circle)

	;; set examination range and bin size (based on loaded values)
	rhorange_eq = [3.4, 8.5] ;; in RE
	phirange_eq = [90., 270.] ;; in degrees

	;;; decide limit and binsize the same time, by how many bins you want, this make sure bincenters always the preset ranges.
	n_bin_rho_eq = 6
	binsizerho_eq = (rhorange_eq(1)-rhorange_eq(0))/n_bin_rho_eq
	binsizephi_eq = (phirange_eq(1)-phirange_eq(0))/n_bin_phi
	
	;;; r-phi dist
	bin2d, rho_eq_dfb, phi_eq_dfb, data_nouse, xrange = rhorange_eq, yrange = phirange_eq, binsize = [binsizerho_eq, binsizephi_eq], binhistogram = counts_dfb_rhophi_eq, xcenters = rhocenters_eq, ycenters = phicenters_eq
	print, total(counts_dfb_rhophi_eq)
	;;; store data for the use of MAIN_XYZ_DIST_PLOT
	;;; not normalized
	store_data, 'poseq_rhophi', data={rho:rhocenters_eq, phi:phicenters_eq, n:counts_dfb_rhophi_eq}
	tplot_save, 'poseq_rhophi', filename = save_folder+'/poseq_rhophi'
endif
stop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;; for normalization, start from here ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; if events are changed, no need to run this again ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; the range used by selection
;cut_first = 'yes'
cut_first = 'no'
rrange_select = [3.5, 6.]
xrange_select = [-6., 0.]
yrange_select = [-6., 6.]
zrange_select = [-10., 10.]

;; get the minutes THEMIS spend in each bin
dim_counts_rhophi = dimen(counts_dfb_rhophi)
counts_rhophi = dblarr(dim_counts_rhophi(0), dim_counts_rhophi(1))
if strcmp(project, 'yes') then begin
	dim_counts_rhophi_eq = dimen(counts_dfb_rhophi_eq)
	counts_rhophi_eq = dblarr(dim_counts_rhophi_eq(0), dim_counts_rhophi_eq(1))
endif

for i = 0, n_elements(seasons[0,*])-1 do begin
  trange_season = time_double(seasons(*,i))
  l_season = trange_season(1)-trange_season(0)
  l_share = l_season/split
  for j = 0, split-1 do begin
	trange_load = [trange_season(0)+j*l_share, trange_season(0)+(j+1)*l_share]
  	del_data, 'th?_state_pos*'
	;rbsp_load, probes = probes, datatype = 'pos', trange = trange_load, /tclip, rbsp_folder = rbsp_folder
	load_bin_data, probes = probes, datatype = 'pos_rbsp', trange = trange_load, /tclip, datafolder = pos_rbsp_folder
  	for k = 0, n_elements(probes)-1 do begin
  	  sc = probes(k)
	  if tv_exist('th'+sc+'_state_pos_tclip') then begin
  	  	get_data, 'th'+sc+'_state_pos_tclip', data = data
	  	t_4s = data.x
  	  	x_4s = data.y[*,0]/6371.
  	  	y_4s = data.y[*,1]/6371.
  	  	z_4s = data.y[*,2]/6371.
		r_4s = sqrt(x_4s^2+y_4s^2+z_4s^2)
		;; trim data to be within range
		i_within = where((x_4s ge xrange_select[0]) and (x_4s le xrange_select[1]) and (y_4s ge yrange_select[0]) and (y_4s le yrange_select[1]) and (z_4s ge zrange_select[0]) and (z_4s le zrange_select[1]) and (r_4s gt rrange_select[0]) and (r_4s lt rrange_select[1]), n_within)
		if strcmp(cut_first, 'yes') then begin
			if n_within gt 0 then begin
				t_4s = t_4s[i_within]
				x_4s = x_4s[i_within]
				y_4s = y_4s[i_within]
				z_4s = z_4s[i_within]
				r_4s = r_4s[i_within]
			endif else continue
		endif
		;;; these are 4-sec data, need to reduce to 1-min data
		n_pts = floor((t_4s[-1]-t_4s[0])/60.)
		if n_pts lt 1 then continue
		t = dindgen(n_pts+1)*60.+t_4s[0]
		x = interpol(x_4s, t_4s, t)
		y = interpol(y_4s, t_4s, t)
		z = interpol(z_4s, t_4s, t)

  	  	rho = sqrt(x^2+y^2)
		phi = atan2(y, x, /degrees, /full_circle)
  	  	;;; original locations, only consider when satellite is in the location range
  	  	i_bin = where((rho ge rhorange[0]) and (rho le rhorange[1]) and (phi ge phirange[0]) and (phi le phirange[1]) and (z ge zrange[0]) and (z le zrange[1]))
	  	if i_bin(0) ne -1 then begin
			rho = rho(i_bin)
  	  		phi = phi(i_bin)
  	  		bin2d, rho, phi, dblarr(n_elements(i_bin))+1, xrange = rhorange, yrange = phirange, binsize = [binsizerho, binsizephi], binhistogram = counts_rhophi_temp, xcenters = rhocenters, ycenters = phicenters
  	  		counts_rhophi = counts_rhophi+counts_rhophi_temp
	  	endif ; if of inside range
		;;; project to equatorial plane
		if strcmp(project, 'yes') then begin
			store_data, 'th'+sc+'_state_pos_RE_tclip', data = {x:t, y:[[x], [y], [z]]} 
			ttrace2equator96, 'th'+sc+'_state_pos_RE_tclip', imf_folder = imf_folder, vsw_folder = vsw_folder, nisw_folder = nisw_folder, dst_folder = dst_folder
			get_data, 'th'+sc+'_efoot', t_eq, data_eq
  	  		x_eq = data_eq(*,0)
  	  		y_eq = data_eq(*,1)
  	  		rho_eq = sqrt(x_eq^2+y_eq^2)
			phi_eq = atan2(y_eq, x_eq, /degrees, /full_circle)
  	  		i_bin = where((rho_eq ge rhorange_eq[0]) and (rho_eq le rhorange_eq[1]) and (phi_eq ge phirange_eq[0]) and (phi_eq le phirange_eq[1]) and (z ge zrange[0]) and (z le zrange[1]), n_bin)
	  		if n_bin gt 0 then begin
				rho_eq = rho_eq(i_bin)
  	  			phi_eq = phi_eq(i_bin)
  	  			bin2d, rho_eq, phi_eq, dblarr(n_bin)+1, xrange = rhorange_eq, yrange = phirange_eq, binsize = [binsizerho_eq, binsizephi_eq], binhistogram = counts_rhophi_temp_eq, xcenters = rhocenters_eq, ycenters = phicenters_eq
  	  			counts_rhophi_eq = counts_rhophi_eq+counts_rhophi_temp_eq
	  		endif ; if of inside range
		endif
	  endif ; if of existing position data
  	endfor ; for of probes
	;;; free memory
	heap_gc
  endfor ; for of splits
endfor ; for of seasons

;;; orbit counts for diagnose use
store_data, 'pos_rhophi_orbit', data={rho:rhocenters, phi:phicenters, n:counts_rhophi}
tplot_save, 'pos_rhophi_orbit', filename = save_folder+'/pos_rhophi_orbit'
;; if too less orbit time (in minutes), set to be NaN
orbit_mt = 60
;orbit_mt = 5*180.
i_enough_rhophi = where(counts_rhophi lt orbit_mt, n_enough_rhophi)
if n_enough_rhophi gt 0 then counts_rhophi(i_enough_rhophi) = !values.f_nan

;; get the rate of events (#/1000min of orbit time) and plot
events_n_per_min_rhophi = counts_dfb_rhophi*1000./double(counts_rhophi)
;;; store data for the use of MAIN_XYZ_DIST_PLOT
store_data, 'pos_rhophi_normal', data={rho:rhocenters, phi:phicenters, n:events_n_per_min_rhophi}
tplot_save, 'pos_rhophi_normal', filename = save_folder+'/pos_rhophi_normal'

;;;;; projected distribution
if strcmp(project, 'yes') then begin
	;;; orbit counts for diagnose use
	store_data, 'poseq_rhophi_orbit', data={rho:rhocenters, phi:phicenters, n:counts_rhophi_eq}
	tplot_save, 'poseq_rhophi_orbit', filename = save_folder+'/poseq_rhophi_orbit'
	i_enough_rhophi = where(counts_rhophi_eq lt orbit_mt, n_enough_rhophi)
	if n_enough_rhophi gt 0 then counts_rhophi_eq(i_enough_rhophi) = !values.f_nan
	;; get the rate of events (#/1000min of orbit time) and plot
	events_n_per_min_rhophi_eq = counts_dfb_rhophi_eq*1000./double(counts_rhophi_eq)
	;;; store data for the use of MAIN_XYZ_DIST_PLOT
	store_data, 'poseq_rhophi_normal', data={rho:rhocenters_eq, phi:phicenters_eq, n:events_n_per_min_rhophi_eq}
	tplot_save, 'poseq_rhophi_normal', filename = save_folder+'/poseq_rhophi_normal'
endif

stop
end
