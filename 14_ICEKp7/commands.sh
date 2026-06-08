
python3 extract_gbk.py MHG0286805.1 MHG0286858.1

       python3 extract_gbk.py WP_039504553.1 WP_075277962.1
python3 extract_gbk.py  WP_406643116.1 WP_039498696.1



conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p ICEKp7.clinker.html ICEKp7.gb *.gbk




