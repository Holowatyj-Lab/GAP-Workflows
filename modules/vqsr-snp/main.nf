/*
Build variant recalibration model for SNPs and apply
*/
process VQSR_SNP {
  tag "$cohort_vcf"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/reports",
    mode: "copy",
    pattern: "*.{recal,tranches,R}"
  )

  publishDir(
    "${params.out}/cohort-vcfs",
    mode: "copy",
    pattern: "*.vcf*"
  )

  input:
  tuple(
    path(cohort_vcf),
    path(cohort_vcf_index)
  )

  output:
  path("*.log")
  tuple(
    path("cohort-snp-recal-99.5.vcf.gz"),
    path("cohort-snp-recal-99.5.vcf.gz.tbi"),
    emit: cohort_snp_recal_vcf
  )


  """
  gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=2" VariantRecalibrator \
    -tranche 100.0 -tranche 99.95 -tranche 99.9 \
    -tranche 99.5 -tranche 99.0 -tranche 97.0 \
    -tranche 96.0 -tranche 95.0 -tranche 94.0 \
    -tranche 93.5 -tranche 93.0 -tranche 92.0 \
    -tranche 91.0 -tranche 90.0 \
    -R ${params.ref} \
    -V ${cohort_vcf} \
    --resource:hapmap,known=false,training=true,truth=true,prior=15.0 \
        ${params.hapmap}  \
    --resource:omni,known=false,training=true,truth=false,prior=12.0 \
        ${params.omni} \
    --resource:1000G,known=false,training=true,truth=false,prior=10.0 \
        ${params.phase1} \
    --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 \
        ${params.dbsnp} \
    -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR  \
    -mode SNP \
    -O snp_vqsr-${params.gendb}.recal \
    --tranches-file snp_vqsr-${params.gendb}.tranches \
    --rscript-file snp_vqsr-${params.gendb}.plots.R \
    --dont-run-rscript \
    2> vqsr_build_snp-${params.gendb}.log


  gatk --java-options "-Xms2G -Xmx2G -XX:ParallelGCThreads=2" ApplyVQSR \
    -R ${params.ref} \
    -V ${cohort_vcf} \
    -O cohort-snp-recal-99.5.vcf.gz \
    --truth-sensitivity-filter-level 99.5 \
    --tranches-file snp_vqsr-${params.gendb}.tranches \
    --recal-file snp_vqsr-${params.gendb}.recal \
    -mode SNP \
    2> vqsr_apply_snp-${params.gendb}.log
  """
}