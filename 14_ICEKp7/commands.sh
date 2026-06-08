
python3 extract_gbk.py MHG0286805.1 MHG0286858.1

conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p ICEKp7.clinker.html ICEKp7.gb *.gbk




