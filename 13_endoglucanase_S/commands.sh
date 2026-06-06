


python3 extract_gbk.py MHG0286677.1 MHG0286683.1
python3 extract_gbk.py WP_010280900.1 WP_014914900.1


conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml




clinker -p  DQ.WP_010280900.1_to_WP_014914900.1.gbk  NAK_239.WP_010280900.1_to_WP_014914900.1.gbk  PP1.3.MHG0286677.1_to_MHG0286683.1.gbk



