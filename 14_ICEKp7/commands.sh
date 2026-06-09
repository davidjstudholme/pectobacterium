
python3 extract_gbk.py MBN3101359.1 MBN3101231.1
python3 extract_gbk.py WP_015730138.1 MBN3183672.1
python3 extract_gbk.py MBN3097640.1 MBN3097686.1
python3 extract_gbk.py MBN3163597.1 MBN3163643.1
python3 extract_gbk.py MFP9462767.1 MFP9462748.1
python3 extract_gbk.py MHG0286806.1 MHG0286858.1




conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p ICEKp7.clinker.html ICEKp7.gb *.gbk




