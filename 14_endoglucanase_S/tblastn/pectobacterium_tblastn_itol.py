#!/usr/bin/env python3
"""Screen genome FASTAs for a protein using local tblastn and write iTOL binary annotations.
Dependencies: BLAST+ (tblastn, makeblastdb), Python 3 standard library.
"""
import argparse
import csv
import math
import subprocess
import sys
import tempfile
from pathlib import Path

FIELDS = ['qseqid','sseqid','pident','length','qstart','qend','sstart','send','evalue','bitscore','qcovhsp']
SUFFIXES = ('.fna', '.fasta', '.fa', '.ffn')

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--genomes', required=True, type=Path, help='Directory containing one FASTA assembly per genome')
    p.add_argument('--protein', required=True, type=Path, help='FASTA of reference protein')
    p.add_argument('--outdir', default=Path('mhg0286679_results'), type=Path)
    p.add_argument('--mapping', type=Path, help='Optional TSV with columns genome_id and itol_id')
    p.add_argument('--threads', type=int, default=4)
    p.add_argument('--identity', type=float, default=40.0, help='Minimum identity for Present (default 40)')
    p.add_argument('--coverage', type=float, default=80.0, help='Minimum HSP query coverage for Present (default 80)')
    p.add_argument('--evalue', type=float, default=1e-5, help='BLAST search E-value cutoff')
    a = p.parse_args()
    if not a.genomes.is_dir(): p.error('--genomes must point to an existing directory')
    if not a.protein.is_file(): p.error('--protein FASTA does not exist')
    if a.threads < 1: p.error('--threads must be >= 1')
    files = sorted(f for f in a.genomes.iterdir() if f.is_file() and f.name.lower().endswith(SUFFIXES))
    if not files: p.error('No .fa/.fna/.fasta/.ffn files were found')
    a.outdir.mkdir(parents=True, exist_ok=True)
    ids = {f.stem: f.stem for f in files}
    if len(ids) != len(files): p.error('Genome filenames must have unique stems')
    if a.mapping:
        with a.mapping.open(newline='') as fh:
            reader = csv.DictReader(fh, delimiter='\t')
            if not {'genome_id','itol_id'} <= set(reader.fieldnames or []): p.error('Mapping TSV must have genome_id and itol_id columns')
            for row in reader:
                if row['genome_id'] not in ids: p.error(f"Mapping references unknown genome: {row['genome_id']}")
                ids[row['genome_id']] = row['itol_id'].strip()
    if len(set(ids.values())) != len(ids) or not all(ids.values()): p.error('iTOL IDs must be nonempty and unique')
    all_rows=[]; all_hits=[]
    with tempfile.TemporaryDirectory(prefix='tblastn_') as td:
        db = str(Path(td)/'assembly')
        for i, f in enumerate(files, 1):
            genome = f.stem
            print(f'[{i}/{len(files)}] {genome}', file=sys.stderr)
            try:
                subprocess.run(['makeblastdb','-in',str(f.resolve()),'-dbtype','nucl','-out',db],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,text=True)
                result=subprocess.run(['tblastn','-query',str(a.protein.resolve()),'-db',db,
                    '-evalue',str(a.evalue),'-num_threads',str(a.threads),'-seg','no',
                    '-outfmt','6 '+' '.join(FIELDS)],check=True,capture_output=True,text=True)
            except FileNotFoundError as ex:
                sys.exit(f'ERROR: BLAST+ command not found: {ex.filename}')
            except subprocess.CalledProcessError as ex:
                sys.exit(f'ERROR processing {f.name}: {ex.stderr}')
            matches=[]
            for line in result.stdout.splitlines():
                parts=line.split('\t')
                if len(parts)!=len(FIELDS): sys.exit(f'Unexpected BLAST format in {f.name}')
                h=dict(zip(FIELDS,parts))
                for col in ('pident','bitscore','qcovhsp','evalue'):
                    h[col]=float(h[col])
                h['genome_id']=genome; h['itol_id']=ids[genome]
                matches.append(h)
                all_hits.append(h)
            # Only a single HSP is used for conservative 'present' calls.
            # A protein split across contigs or HSPs is reported as uncertain for inspection.
            strong=[h for h in matches if h['pident']>=a.identity and h['qcovhsp']>=a.coverage]
            detectable=[h for h in matches if h['pident']>=25 and h['qcovhsp']>=20]
            if strong: status='Present'; ranked=strong
            elif detectable or matches: status='Uncertain'; ranked=detectable or matches
            else: status='Not detected'; ranked=[]
            best=max(ranked,key=lambda h:(h['qcovhsp'],h['bitscore'])) if ranked else None
            all_rows.append({'genome_id':genome, 'itol_id':ids[genome], 'status':status,
                'contig':best['sseqid'] if best else '',
                'identity_pct':f"{best['pident']:.2f}" if best else '',
                'query_coverage_pct':f"{best['qcovhsp']:.1f}" if best else '',
                'evalue':f"{best['evalue']:.3g}" if best else '',
                'bitscore':f"{best['bitscore']:.1f}" if best else '',
                'number_of_hsps':len(matches)})
    with (a.outdir/'protein_screen_summary.tsv').open('w',newline='') as fh:
        w=csv.DictWriter(fh,fieldnames=list(all_rows[0]),delimiter='\t'); w.writeheader(); w.writerows(all_rows)
    with (a.outdir/'all_tblastn_hits.tsv').open('w',newline='') as fh:
        w=csv.DictWriter(fh,fieldnames=['genome_id','itol_id']+FIELDS,delimiter='\t',extrasaction='ignore')
        w.writeheader(); w.writerows(all_hits)
    with (a.outdir/'itol_MHG0286679_presence.txt').open('w') as fh:
        fh.write('DATASET_BINARY\nSEPARATOR TAB\nDATASET_LABEL\tMHG0286679.1\nCOLOR\t#16865D\n')
        fh.write('FIELD_SHAPES\t1\t2\nFIELD_LABELS\tPresent\tUncertain\n')
        fh.write('FIELD_COLORS\t#16865D\t#D99A25\nSHOW_LABELS\t1\nDATA\n')
        for r in all_rows:
            presence={'Present':'1','Not detected':'0','Uncertain':'-1'}[r['status']]
            uncertain='1' if r['status']=='Uncertain' else '-1'
            fh.write(f"{r['itol_id']}\t{presence}\t{uncertain}\n")
    print('\nResults:', a.outdir.resolve())
    for status in ('Present','Uncertain','Not detected'):
        print(f"{status}: {sum(r['status']==status for r in all_rows)}")
    print('NOTE: Calls use best single HSP; inspect uncertain hits for split or divergent genes.')

if __name__=='__main__': main()
