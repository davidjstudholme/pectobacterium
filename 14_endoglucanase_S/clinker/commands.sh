


python3 extract_gbk.py MHG0286677.1 MHG0286683.1
python3 extract_gbk.py WP_010280900.1 WP_014914900.1
python3 extract_gbk.py WP_010280900.1 WP_039500482.1
python3 extract_gbk.py WP_039500492.1 WP_040034872.1
python3 extract_gbk.py KHT20221.1 KHT20215.1
python3 extract_gbk.py WP_010280900.1 WP_075278061.1
python3 extract_gbk.py MHG0321483.1 MHG0321477.1
python3 extract_gbk.py MHG0333338.1 MHG0333344.1

python3 extract_gbk.py MBN3180720.1 MBN3180725.1
python3 extract_gbk.py MFP9459456.1 MFP9459461.1
python3 extract_gbk.py PPE63548.1 PPE63553.1
python3 extract_gbk.py MBN3167131.1 MBN3167136.1

python3 extract_gbk.py KHT07796.1 KHT07801.1
python3 extract_gbk.py MBN3103748.1 MBN3103753.1


conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p endoglucanase.clinker.html *.gbk




