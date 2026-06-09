

python3 extract_gbk.py MHG0286805.1 MHG0286858.1 
python3 extract_gbk.py WP_039500299.1 WP_406643116.1 
python3 extract_gbk.py WP_011093072.1 WP_015730843.1 
python3 extract_gbk.py MHG0321355.1	 MHG0321302.1 
python3 extract_gbk.py MHG0333466.1	 MHG0333519.1 
python3 extract_gbk.py MFP9462765.1 MFP9462748.1 
python3 extract_gbk.py MBN3180606.1 MBN3183672.1 
python3 extract_gbk.py  PPE61137.1 PPE61187.1
python3 extract_gbk.py MBN3167015.1 MBN3163643.1 
python3 extract_gbk.py MBN3099852.1 MBN3097686.1 
python3 extract_gbk.py MBN3101250.1 MBN3101231.1 
python3 extract_gbk.py  KHS98772.1 KHS98812.1
python3 extract_gbk.py WP_011093072.1 WP_014914765.1 
python3 extract_gbk.py WP_205592588.1 WP_205594531.1 




conda activate clinker_env

conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


clinker -p ICEKp7.clinker.html ICEKp7.gb NAK*.gb *.gbk




