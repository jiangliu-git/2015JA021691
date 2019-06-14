pro main_superpose_duration
;;; use the superpose method to determine the duration of DFBs, same as Liu et al. 2014.
;;; !!!! Tail too long, cannot decide, do not try again !!!

;;; superpose quantities 
thm_init
computer = 'I:'
;computer = '/home/jliu'
@folders

;; superpose range before and after
minutes_show = 3.

;;; the range for average
aft_range = [2., 3.]

del_data, '*'
events = load_list(list_folder+'/dfb_rbsp_subboth_list_good.txt', folder = list_folder)
;;;; Bz and Bttl
b_q_list = event_status_instant(events, 'fgs_rbsp', pre_time = 2.5, time_length = 1, detrend_model = detrend_model, datafolder=rbsp_folder)
bzttl_dtr = b_q_list[4:5, *]
superpose_data_fast, 'fgs_rbsp', components='z', /total, t0p_list=[events[0, *], events[3, *]], pre=minutes_show+0.5, after=minutes_show+0.5, datafolder=rbsp_folder, detrend_v=bzttl_dtr

b_name = 'fgs_gsm_z_superpose_quartiles'
split_vec, b_name
b_name_med = b_name+'_y'

;;; begin
get_data, b_name_med, data = dbz
time_clip, b_name_med, time_double('2000 1 1')+aft_range(0)*60., time_double('2000 1 1')+aft_range(1)*60.
get_data, b_name_med+'_tclip', data = after
t_end = dbz.x(n_elements(dbz.x)-1)
no_use = max(dbz.y, i_max, /nan)
dbz_behind = dbz.y(i_max:*)
t_behind = dbz.x(i_max:*)
after_v = mean(after.y, /nan)
i_neg = where(dbz_behind-after_v lt 0)
i_first_neg = i_neg(0)
i_last_pos = i_neg(0)-1
t_cut = interpol(t_behind([i_last_pos, i_first_neg]), dbz_behind([i_last_pos, i_first_neg]), after_v)
print, 'Duration (secs):'
print, t_cut-time_double('2000 1 1')
store_data, 'horiz_line', data = {x:[t_cut-0.06*(t_end-t_cut), t_end], y:[after_v, after_v]}
store_data, 'vert_line', data = {x:[t_cut, t_cut], y:[-2, after_v+(after_v)*0.08]}
options, 'horiz_line', thick = 0.7
options, 'vert_line', thick = 0.7

store_data, b_name+'_lines', data=[b_name, 'horiz_line', 'vert_line']
tplot, b_name, trange = [time_double('0 1 1')-minutes_show*60., time_double('0 1 1')+minutes_show*60.], title = 'Determining DFB Duration'
timebar, '0 1 1', line = 1
end
