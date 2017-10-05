docker run -ti --entrypoint=tini -p 8888:8888 -v "$(pwd):/home/mlo/notebook" ntxvm016.iccluster.epfl.ch:5000/mlo_ml bash /usr/local/bin/start-notebook.sh
