


python3 extract_gbk.py MHG0286677.1 MHG0286683.1
python3 extract_gbk.py WP_010280900.1 WP_014914900.1
python3 extract_gbk.py WP_010280900.1 WP_039500482.1
python3 extract_gbk.py WP_039500492.1 WP_040034872.1
python3 extract_gbk.py KHT20221.1 KHT20215.1
python3 extract_gbk.py WP_010280900.1 WP_075278061.1
python3 extract_gbk.py MHG0321483.1 MHG0321477.1
python3 extract_gbk.py MHG0333338.1 MHG0333344.1
python3 extract_gbk.py MFP9459458.1 MFP9459461.1
python3 extract_gbk.py PPE63548.1 PPE63551.1
python3 extract_gbk.py MBN3180720.1 MBN3180723.1
python3 extract_gbk.py MBN3167131.1 MBN3167134.1
python3 extract_gbk.py MBN3099733.1 MBN3099736.1
python3 extract_gbk.py KHT07796.1 KHT07799.1
python3 extract_gbk.py MBN3103752.1 MBN3103753.1

conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p endoglucanase.clinker.html  DQ.WP_010280900.1_to_WP_014914900.1.gbk  NAK_239.WP_010280900.1_to_WP_014914900.1.gbk  PP1.3.MHG0286677.1_to_MHG0286683.1.gbk SM.WP_010280900.1_to_WP_039500482.1.gbk BY2.WP_039500492.1_to_WP_040034872.1.gbk Y65.scaffold9.KHT20221.1_to_KHT20215.1.gbk BC1.WP_010280900.1_to_WP_075278061.1.gbk

clinker -p endoglucanase.clinker.html BC1.WP_010280900.1_to_WP_075278061.1.gbk  NAK252.MBN3103752.1_to_MBN3103753.1.gbk NAK700.MFP9459458.1_to_MFP9459461.1.gbk SM.WP_010280900.1_to_WP_039500482.1.gbk BY2.WP_039500492.1_to_WP_040034872.1.gbk  NAK432.MBN3180720.1_to_MBN3180723.1.gbk  PP1.3.MHG0286677.1_to_MHG0286683.1.gbk Y29.KHT07796.1_to_KHT07799.1.gbk DQ.WP_010280900.1_to_WP_014914900.1.gbk   NAK434.MBN3099733.1_to_MBN3099736.1.gbk  PP2.MHG0321483.1_to_MHG0321477.1.gbk Y65.scaffold9.KHT20221.1_to_KHT20215.1.gbk F152.PPE63548.1_to_PPE63551.1.gbk NAK435.MBN3167131.1_to_MBN3167134.1.gbk  PP5.MHG0333338.1_to_MHG0333344.1.gbk


clinker -p endoglucanase.clinker.html *.gbk




