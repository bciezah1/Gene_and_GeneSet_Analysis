#!/bin/bash

model=$1
input_path=/mnt/vast/hpc/gtosto_lab/GT_ADMIX/Basilio_08_19_2022/magma_v1.10/META_ANALYSIS_01_28_2025
output_path=/mnt/vast/hpc/gtosto_lab/GT_ADMIX/Basilio_08_19_2022/magma_v1.10/META_ANALYSIS_01_28_2025

# Step 1: Annotation
snploc=$input_path/$model/meta_"$model"_double.input.snp.chr.pos.txt
ncbi37="./NCBI38/NCBI38.gene.loc"

echo "Starting Step 1: Annotation..."
echo "input"
echo $snploc

./magma --annotate --snp-loc ${snploc} --gene-loc ${ncbi37} --out $output_path/$model/meta_"$model"_double.input
if [ $? -ne 0 ]; then
  echo "Error in Step 1: Annotation"
  exit 1
fi
echo "Step 1: Annotation completed successfully."

# Step 2: Gene-based Analysis
ref="./g1000_amr"
echo "Starting Step 2: Gene-based Analysis..."
./magma --bfile $ref --pval $input_path/$model/meta_"$model"_double.input.p.txt N=11469 --gene-annot $input_path/$model/meta_"$model"_double.input.genes.annot --out $output_path/$model/meta_"$model"_double.input
if [ $? -ne 0 ]; then
  echo "Error in Step 2: Gene-based Analysis"
  exit 1
fi
echo "Step 2: Gene-based Analysis completed successfully."

# Step 3: GSEA
geneset="./c5.all.v2024.1.Hs.entrez.gmt"
echo "Starting Step 3: GSEA..."
./magma --gene-results $input_path/$model/meta_"$model"_double.input.genes.raw --set-annot ${geneset} --out $output_path/$model/meta_"$model"_double.input
if [ $? -ne 0 ]; then
  echo "Error in Step 3: GSEA"
  exit 1
fi
echo "Step 3: GSEA completed successfully."

echo "All steps completed successfully."
