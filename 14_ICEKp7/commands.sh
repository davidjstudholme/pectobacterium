
python3 extract_gbk.py WP_039500298.1 WP_039504507.1
python3 extract_gbk.py WP_336880082.1 WP_015730843.1
python3 extract_gbk.py WP_039500298.1 WP_406643116.1
python3 extract_gbk.py PPE61187.1 PPE61137.1
python3 extract_gbk.py MBN3101275.1 MBN3101231.1
python3 extract_gbk.py WP_015730138.1 MBN3183672.1
python3 extract_gbk.py MBN3097640.1 MBN3097686.1
python3 extract_gbk.py MBN3163597.1 MBN3163643.1
python3 extract_gbk.py MFP9462767.1 MFP9462748.1
python3 extract_gbk.py MHG0286806.1 MHG0286858.1
python3 extract_gbk.py MHG0321354.1 MHG0321302.1
python3 extract_gbk.py MHG0333467.1 MHG0333519.1
python3 extract_gbk.py WP_039313895.1 WP_205594531.1
python3 extract_gbk.py KHS98812.1 KHS98772.1

conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p ICEKp7.clinker.html ICEKp7.gb *.gbk




