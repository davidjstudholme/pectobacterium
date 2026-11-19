# Activate the Conda environment
conda activate clinker_env
conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


# Extract from strains BC1, BY2, DQ, PP1, PP2, PP5
python3 extract_gbk.py MHG0286806.1 WP_010281471.1
python3 extract_gbk.py MHG0333467.1 WP_010281471.1
python3 extract_gbk.py WP_039500298.1 WP_010281471.1
python3 extract_gbk.py MHG0321354.1 WP_010281471.1


# Align ICEKp7 to all
clinker -p ICEKp7.all.clinker.html ICEKp7.gb PP1.gb




