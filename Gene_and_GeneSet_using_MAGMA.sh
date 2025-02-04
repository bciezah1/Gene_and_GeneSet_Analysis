#!/bin/bash
###############################################################################
# Script Name: run_magma_analysis.sh
# Description: This script performs a three-step analysis using the MAGMA tool.
#              The steps include Annotation, Gene-based Analysis, and Gene Set
#              Enrichment Analysis (GSEA). It takes two parameters: the model 
#              and cohort names, constructs the appropriate file paths, and 
#              executes the corresponding MAGMA commands.
#
# Usage: ./run_magma_analysis.sh <model> <cohort>
#
# Arguments:
#   model  - A string representing the model type (e.g., "model1").
#   cohort - A string representing the cohort name (e.g., "cohort1").
#
# Prerequisites:
#   - The MAGMA executable must be in the current directory or accessible in PATH.
#   - The required input files (SNP location, gene location, reference files, 
#     and gene sets) must exist at the specified paths.
#
# File Paths:
#   - input_path:  Base directory containing input files organized by cohort.
#   - output_path: Base directory where output files will be stored.
#
# Steps:
#   Step 1: Annotation
#           Uses the MAGMA --annotate command to annotate SNPs with gene locations.
#
#   Step 2: Gene-based Analysis
#           Uses the MAGMA --bfile and --pval commands to perform gene-based analysis.
#
#   Step 3: Gene Set Enrichment Analysis (GSEA)
#           Uses the MAGMA --gene-results and --set-annot commands to perform GSEA.
#
# Exit Codes:
#   1 - If any of the three steps fails.
#
# Author: Your Name
# Date: YYYY-MM-DD
###############################################################################

# Get model and cohort from command line arguments
model=$1
cohort=$2

# Define input and output paths based on the cohort and model.
input_path=/mnt/vast/hpc/gtosto_lab/GT_ADMIX/Basilio_08_19_2022/magma_v1.10/$cohort
output_path=/mnt/vast/hpc/gtosto_lab/GT_ADMIX/Basilio_08_19_2022/magma_v1.10/$cohort

###############################
# Step 1: Annotation
###############################
# Define SNP location file and gene location file (NCBI37 gene locations).
snploc=$input_path/$model/"$cohort"_"$model"_double.input.snp.chr.pos.txt
ncbi37="./NCBI38/NCBI38.gene.loc"

echo "Starting Step 1: Annotation..."
echo "Input SNP location file: $snploc"

# Run MAGMA annotation
./magma --annotate --snp-loc "${snploc}" --gene-loc "${ncbi37}" --out $output_path/$model/"$cohort"_"$model"_double.input
if [ $? -ne 0 ]; then
  echo "Error in Step 1: Annotation"
  exit 1
fi
echo "Step 1: Annotation completed successfully."

###############################
# Step 2: Gene-based Analysis
###############################
# Define the reference dataset for gene-based analysis.
ref="./g1000_amr"
echo "Starting Step 2: Gene-based Analysis..."

# Run MAGMA gene-based analysis using:
#   --bfile: reference genotype data
#   --pval: p-values file from previous step
#   --gene-annot: gene annotation file generated in Step 1
./magma --bfile $ref \
        --pval $input_path/$model/"$cohort"_"$model"_double.input.p.txt N=290 \
        --gene-annot $input_path/$model/"$cohort"_"$model"_double.input.genes.annot \
        --out $output_path/$model/"$cohort"_"$model"_double.input
if [ $? -ne 0 ]; then
  echo "Error in Step 2: Gene-based Analysis"
  exit 1
fi
echo "Step 2: Gene-based Analysis completed successfully."

###############################
# Step 3: Gene Set Enrichment Analysis (GSEA)
###############################
# Define the gene set annotation file.
geneset="./c5.all.v2024.1.Hs.entrez.gmt"
echo "Starting Step 3: GSEA..."

# Run MAGMA GSEA using:
#   --gene-results: results file from gene-based analysis
#   --set-annot: gene set annotation file
./magma --gene-results $input_path/$model/"$cohort"_"$model"_double.input.genes.raw \
        --set-annot ${geneset} \
        --out $output_path/$model/"$cohort"_"$model"_double.input
if [ $? -ne 0 ]; then
  echo "Error in Step 3: GSEA"
  exit 1
fi
echo "Step 3: GSEA completed successfully."

echo "All steps completed successfully."

