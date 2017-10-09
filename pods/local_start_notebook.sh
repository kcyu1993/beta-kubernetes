docker run -ti --entrypoint=tini -p 8888:8888 -v "$(pwd):/home/mlo/notebooks" ntxvm015.iccluster.epfl.ch/mlo/ml:1.0 bash /usr/local/bin/start-notebook.sh
