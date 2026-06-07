


python3 extract_gbk.py MHG0286677.1 MHG0286683.1
python3 extract_gbk.py WP_010280900.1 WP_014914900.1
python3 extract_gbk.py WP_010280900.1 WP_039500482.1
python3 extract_gbk.py WP_039500492.1 WP_040034872.1
python3 extract_gbk.py KHT20221.1 KHT20215.1
python3 extract_gbk.py WP_010280900.1 WP_075278061.1

conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p endoglucanase.clinker.html  DQ.WP_010280900.1_to_WP_014914900.1.gbk  NAK_239.WP_010280900.1_to_WP_014914900.1.gbk  PP1.3.MHG0286677.1_to_MHG0286683.1.gbk SM.WP_010280900.1_to_WP_039500482.1.gbk BY2.WP_039500492.1_to_WP_040034872.1.gbk Y65.scaffold9.KHT20221.1_to_KHT20215.1.gbk BC1.WP_010280900.1_to_WP_075278061.1.gbk





