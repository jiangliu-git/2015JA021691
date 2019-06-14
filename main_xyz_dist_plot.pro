pro main_xyz_dist_plot
;; generate the plots of or MAIN_XYZ_DIST_FAST. Run it first with proper uncommented lines.
thm_init
@folders

;;;;;;;;;;;;;;;;;;;;;;;;;;; codes for color plots ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; generate the occurence rate values 
varnames_load = ['pos_rhophi', 'pos_rhophi_orbit', 'poseq_rhophi', 'poseq_rhophi_orbit']
for i = 0, n_elements(varnames_load)-1 do begin
	tplot_restore, filename = save_folder+'/'+varnames_load[i]+'.tplot'
endfor

;orbit_mt = 0 ;; turn off
orbit_mt = 500
;;;;;;;; regular
get_data, 'pos_rhophi', data=data ;{x:xcenters, y:ycenters, n:events_n_per_min_xy}
counts_dfb_rhophi = data.n
rhocenters = data.rho
phicenters = data.phi
get_data, 'pos_rhophi_orbit', data=data ;{x:xcenters, y:ycenters, n:events_n_per_min_xy}
counts_rhophi = data.n
i_enough_rhophi = where(counts_rhophi lt orbit_mt, n_enough_rhophi)
;; get the rate of events (#/1000min of orbit time) and plot
if n_enough_rhophi gt 0 then counts_rhophi(i_enough_rhophi) = !values.f_nan
events_n_per_min_rhophi = counts_dfb_rhophi*1000./double(counts_rhophi)
;;; store data for the use of MAIN_XYZ_DIST_PLOT
store_data, 'pos_rhophi_normal', data={rho:rhocenters, phi:phicenters, n:events_n_per_min_rhophi}
;;;;;;;; projected
get_data, 'poseq_rhophi', data=data ;{x:xcenters, y:ycenters, n:events_n_per_min_xy}
counts_dfb_rhophi_eq = data.n
rhocenters_eq = data.rho
phicenters_eq = data.phi
get_data, 'poseq_rhophi_orbit', data=data ;{x:xcenters, y:ycenters, n:events_n_per_min_xy}
counts_rhophi_eq = data.n
i_enough_rhophi = where(counts_rhophi_eq lt orbit_mt, n_enough_rhophi)
if n_enough_rhophi gt 0 then counts_rhophi_eq(i_enough_rhophi) = !values.f_nan
;; get the rate of events (#/1000min of orbit time) and plot
events_n_per_min_rhophi_eq = counts_dfb_rhophi_eq*1000./double(counts_rhophi_eq)
;;; store data for the use of MAIN_XYZ_DIST_PLOT
store_data, 'poseq_rhophi_normal', data={rho:rhocenters_eq, phi:phicenters_eq, n:events_n_per_min_rhophi_eq}

;;;;;;;;;;;;;;;;;;;;;;;;;;; codes for scatter points plots ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; load pos values
list_name = 'dfb_rbsp_subboth_list_good'
list_name_inj = 'dfb_rbsp_subboth_mageis_list_injection'
list_name_noinj = 'dfb_rbsp_subboth_mageis_list_no_injection'
events = load_list(list_name+'.txt', folder = list_folder)
events_inj = load_list(list_name_inj+'.txt', folder = list_folder)
events_noinj = load_list(list_name_noinj+'.txt', folder = list_folder)
pos = datain_simple(save_folder+'/pos_'+list_name+'.dat', dim = 3, type = 'double')
pos_eq = datain_simple(save_folder+'/pos_eq_'+list_name+'.dat', dim = 3, type = 'double')
store_data, 'pos_separate', data={x:pos[0,*], y:pos[1,*]}
store_data, 'poseq_separate', data={x:pos_eq[0,*], y:pos_eq[1,*]}

;;; decide the indicies for three types of events.
n_all = n_elements(events[0,*])
n_inj = n_elements(events_inj[0,*])
n_noinj = n_elements(events_noinj[0,*])
n_unclear = n_all-n_inj-n_noinj
i_inj = intarr(n_inj)
i_noinj = intarr(n_noinj)
i_unclear = intarr(n_unclear)
j_inj = 0
j_noinj = 0
j_unclear = 0
for i = 0, n_all-1 do begin
	case 1 of
	strcmp(events[0,i], events_inj[0,j_inj]): begin
		i_inj[j_inj] = i
		if j_inj lt n_inj-1 then j_inj = j_inj+1
		end
	strcmp(events[0,i], events_noinj[0,j_noinj]): begin
		i_noinj[j_noinj] = i
		if j_noinj lt n_noinj-1 then j_noinj = j_noinj+1
		end
	else: begin
		i_unclear[j_unclear] = i
		if j_unclear lt n_unclear-1 then j_unclear = j_unclear+1
		end
	endcase
endfor	

;;;;;;;;;;;;;;;;;; start plotting
;;; 4 panels
;varnames = ['pos_rhophi', 'pos_rhophi_normal', 'poseq_rhophi', 'poseq_rhophi_normal']
;titles = ['Original', '', 'Equatorial footprint', '']
;labels = ['DFB distribution', 'DFB occurence rate', '', '']
;;; 6 panels
varnames = ['pos_rhophi', 'pos_rhophi_normal', 'pos_separate', 'poseq_rhophi', 'poseq_rhophi_normal', 'poseq_separate']
titles = ['Original', '', '', 'Equatorial footprint', '', '']
labels = ['DFB distribution', 'DFB occurence rate', 'DFB distribution', '', '', '']

n_panels = n_elements(varnames)

left_margin = 0.2
right_margin = 0.07
top_margin = 0.05
bot_margin = 0.07
space_horiz = 0.1
space_vert = 0.01
case n_panels of 
4: begin
	n_p_horiz = 2
	n_p_vert = 2
	size_x = 5
	size_y = 5
	abc = ['(a)', '(b)', '(c)', '(d)']
	end
6: begin
	n_p_horiz = 2
	n_p_vert = 3
	size_x = 5
	size_y = 7.5
	abc = ['(a)', '(b)', '(e)', '(c)', '(d)', '(f)']
	end
endcase
positions = panel_positions([n_p_horiz, n_p_vert], lr_margins = [left_margin, right_margin], bt_margins = [bot_margin, top_margin], space = [space_horiz, space_vert])

popen, pic_folder+'/dfb_pos'
print_options,xsize=size_x,ysize=size_y
for i = 0, n_elements(varnames)-1 do begin
	;;; xtitle and ztitle
	if (i ne 2) and (i ne 5) then begin
		xtitle = ''
		xtickname = replicate(' ', 50)
		if (i eq 0) or (i eq 3) then begin
			ztitle = '# of events'
		endif else begin
			ztitle = '#/1000min orbit time'
		endelse
	endif else begin
		xtickname = ''
		if i eq 2 then begin
			xtitle = 'X [R!dE!n]'
;			xtickname = ['0', ' ', ' ', '-3', ' ', ' ', '-6']
		endif else begin
			xtitle = 'X!deq!n [R!dE!n]'
		endelse
	endelse
	;;; ytitle
;	if (i eq 0) or (i eq 1) then begin ;; 4 panels
	if (i eq 0) or (i eq 1) or (i eq 2) then begin ;; 6 panels
		;ytitle = 'Y!dGSM!n [R!dE!n]'
		ytitle = 'Y [R!dE!n]'
		xrange = [0, -6]
		yrange = [8.5, -8.5]
		xticks = 3
		xminor = 4
	endif else begin
		;ytitle = 'Y!s!dGSM!r!u*!n     [R!dE!n]'
		ytitle = 'Y!deq!n [R!dE!n]'
		xrange = [0, -8.5]
		yrange = [8.5, -8.5]
		xticks = 0
	endelse
	get_data, varnames[i], data=data ;{x:xcenters, y:ycenters, n:events_n_per_min_xy} for color plot, {x:x, y:y} for dot plot
	if strmatch(varnames[i], '*separate') then begin
		plot, data.x, data.y, /nodata, /isotropic, xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, title=titles(i), xtickname = xtickname, xticks = xticks, xminor = xminor, xtitle = xtitle, ytitle = ytitle, /noerase, position = positions[*,i]
		draw_circle, data.x[i_unclear], data.y[i_unclear], 0.05, color_fill = 4, /fill, xrange = xrange, yrange = yrange
		draw_circle, data.x[i_noinj], data.y[i_noinj], 0.07, color_fill = 2, /fill, xrange = xrange, yrange = yrange
		draw_circle, data.x[i_inj], data.y[i_inj], 0.07, color_fill = 6, /fill, xrange = xrange, yrange = yrange
	endif else begin
		plotxyz_polar, data.rho, data.phi*!pi/180, data.n, xrange = xrange, xstyle = 1, yrange = yrange, ystyle = 1, title=titles(i), xtickname = xtickname, xticks = xticks, xminor = xminor, xtitle = xtitle, ytitle = ytitle, ztitle = ztitle, /trim, /noerase, position = positions[*,i]
	endelse
	xyouts, !x.crange[0]+0.7*(!x.crange[1]-!x.crange[0]), !y.crange[0]+0.9*(!y.crange[1]-!y.crange[0]), abc[i], /data
;	xyouts, !x.crange[0]+0.12*(!x.crange[1]-!x.crange[0]), !y.crange[0]+0.5*(!y.crange[1]-!y.crange[0]), description, /data, align = 0.5, orientation = 90
	xyouts, !x.crange[0]-0.8*(!x.crange[1]-!x.crange[0]), !y.crange[0]+0.5*(!y.crange[1]-!y.crange[0]), labels[i], /data, align = 0.5, orientation = 90
endfor
pclose

stop
end
