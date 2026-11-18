# Activate the Conda environment
conda activate clinker_env
conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


# Extract from strains PP1
python3 extract_gbk.py MHG0288642.1 MHG0288679.1

# Extract from strains PP2
python3 extract_gbk.py WP_406640865.1 MHG0323268.1	

# Extract from strains PP5
python3 extract_gbk.py MHG0334448.1 MHG0334411.1

# Extract from strains DQ
python3 extract_gbk.py WP_406640865.1 WP_406640863.1	

# Extract from strains BC1
#python3 extract_gbk.py ????? 



# Align ICEKp7 to all
clinker -p ICE.all.clinker.html *.gbk




