import matlab.engine
eng = matlab.engine.start_matlab()
eng.add(nargout=0)
eng.quit()
