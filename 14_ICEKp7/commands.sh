
python3 extract_gbk.py MHG0286748.1 MHG0286787.1

conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p ICEKp7.clinker.html ICEKp7.gb *.gbk




