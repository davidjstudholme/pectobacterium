import sys
from Bio import SeqIO
from pathlib import Path


def find_cds_by_protein_id(record, protein_id):
    """
    Find a CDS feature by protein_id.
    Returns (start, end) in 0-based coordinates, or None.
    """
    for feature in record.features:
        if feature.type != "CDS":
            continue

        pids = feature.qualifiers.get("protein_id", [])
        if protein_id in pids:
            return int(feature.location.start), int(feature.location.end)

    return None


def main(pid_a, pid_b):
    for gb_file in Path(".").glob("*.gb"):
        print(f"Processing {gb_file}")

        records = list(SeqIO.parse(gb_file, "genbank"))
        if not records:
            print("  ⚠ No records found")
            continue

        for record in records:
            loc_a = find_cds_by_protein_id(record, pid_a)
            loc_b = find_cds_by_protein_id(record, pid_b)

            if not loc_a or not loc_b:
                print(f"  ✖ Missing {pid_a} or {pid_b}")
                continue

            start = min(loc_a[0], loc_b[0])
            end   = max(loc_a[1], loc_b[1])

            subrecord = record[start:end]

            subrecord.id = f"{record.id}_{pid_a}_to_{pid_b}"
            subrecord.name = subrecord.id
            subrecord.description = (
                f"Region from protein_id {pid_a} to {pid_b}"
            )

            out_file = gb_file.with_suffix(f".{pid_a}_to_{pid_b}.gbk")
            SeqIO.write(subrecord, out_file, "genbank")

            print(f"  ✔ Wrote {out_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python extract_region_by_protein_id.py <protein_id_A> <protein_id_B>")
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])

