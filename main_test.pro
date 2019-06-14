pro main_test
trange = ['13 7 20 22 23 1', '13 7 21 3 2 1']
probe = 'b'
;timespan, trange[0], time_double(trange[1])-time_double(trange[0]), /sec
rbsp_load, datatype = 'hope_pa', level = 3, trange=trange, probe=probe, /tclip
stop
end
