pro main_modify_list
;; remove bad or combine lists
computer = 'I:'
@folders

;;;;;;;; remove bad counts ;;;;;;;;;;;
;;;;;; 10-min average removed list, season 1
;list_name = 'dfb_rbsp_sub10_list_lead_tail'
;events = load_list(list_name+'.txt', folder = list_folder)
;i_bad = [1,2,4,5,9,18,19,21,56,65,68,0,6,7,10,22,64]
;i_all = indgen(n_elements(events[0,*]))
;i_good = setdifference(i_all, i_bad)
;events_out = events[*,i_good]
;output_txt, events_out, filename = 'dfb_rbsp_sub10_list_good.txt'


;;;;;;;; combine lists ;;;;;;;;;;;;;;
list1 = 'dfb_rbsp_submodel_list_good.txt'
list2 = 'dfb_rbsp_sub10_list_good.txt'
events1 = load_list(list1, folder = list_folder)
events2 = load_list(list2, folder = list_folder)

;; use events1 as more correct, search events2 for different events
events2_use = ['', '', '', '']
for i = 0, n_elements(events2[0,*])-1 do begin
	i_overlap = where((abs(time_double(events2[0,i])-time_double(events1[0,*])) lt 3*60.) and strcmp(events2[3,i], events1[3,*]), n_overlap)
	if n_overlap eq 0 then begin
		events2_use = [[events2_use], [events2[*,i]]]
	endif
endfor

if n_elements(events2_use[0,*]) gt 1 then events2_use = events2_use[*, 1:*]

events_all = [[events1], [events2_use]]
times = time_double(events_all[0,*])
i_sort = sort(times)
events_combined = events_all[*, i_sort]

stop
output_txt, events_combined, filename = list_folder+'/dfb_rbsp_subboth_list_good.txt'

stop
end
