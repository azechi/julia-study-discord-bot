
repl:
	docker run \
	       	-it \
		-e JULIA_NUM_THREADS=$(shell getconf _NPROCESSORS_ONLN) \
		--env-file .env \
		-v "$(HOME)/.julia":/root/.julia \
		-v "$(CURDIR)":/root/work \
		-w /root/work \
		julia

jupyter: 
	docker run -p 8888:8888 \
		-v "$(PWD)":/home/jovyan/work \
		jupyter/datascience-notebook \
		start.sh jupyter lab \
		--LabApp.token=''

