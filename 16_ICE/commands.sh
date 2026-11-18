# Activate the Conda environment
conda activate clinker_env
conda list -n clinker_env > clinker_env_packages.txt
conda env export > clinker_env.yaml


# Extract from strains BC1, BY2, DQ, PP1, PP2, PP5
python3 extract_gbk.py MHG0288642.1 MHG0288679.1

# Align ICEKp7 to all
clinker -p ICEKp7.all.clinker.html ICEKp7.gb *.gbk

clinker -p  test.html PP1.MHG0288642.1_to_MHG0288679.1.gbk PP2.gb



