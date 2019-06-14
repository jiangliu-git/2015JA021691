pro example
trange = ['13 11 14 2 40', '12 11 14 2 50']
sc = 'r' ;; RBSP-A is called 'thr', rbsp-B is called 'ths'
rbsp_folder = 'SETHERE'
rbsp_load, trange=trange, probe=sc, datatype = 'mageis', /tclip, rbsp_folder = rbsp_folder, level = 2
tplot, 'th'+sc+'_mageis_pspec'
end
