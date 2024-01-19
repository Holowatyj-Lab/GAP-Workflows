/*
Build variant recalibration model for indels and apply
*/
process VQSR_INDEL {
  tag "$cohort_snp_recal_vcf"

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
    path(cohort_snp_recal_vcf),
    path(cohort_snp_recal_vcf_index)
  )

  output:
  path("*.log")
  tuple(
    path("cohort-snp-indel-recal-99.5.vcf.gz"),
    path("cohort-snp-indel-recal-99.5.vcf.gz.tbi"),
    emit: cohort_snp_indel_recal_vcf
  )

  """
  gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=2" VariantRecalibrator \
    -tranche 100.0 -tranche 99.95 -tranche 99.9 \
    -tranche 99.5 -tranche 99.0 -tranche 97.0 \
    -tranche 96.0 -tranche 95.0 -tranche 94.0 \
    -tranche 93.5 -tranche 93.0 -tranche 92.0 \
    -tranche 91.0 -tranche 90.0 \
    -R ${params.ref} \
    -V ${cohort_snp_recal_vcf} \
    --resource:mills,known=false,training=true,truth=true,prior=12.0 \
      ${params.mills} \
    --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 \
      ${params.dbsnp} \
    -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP \
    -mode INDEL \
    -O indel_vqsr-${params.gendb}.recal \
    --tranches-file indel_vqsr-${params.gendb}.tranches \
    --rscript-file indel_vqsr-${params.gendb}.plots.R \
    --dont-run-rscript \
    2> vqsr_build_indel-${params.gendb}.log

  gatk --java-options "-Xms2G -Xmx2G -XX:ParallelGCThreads=2" ApplyVQSR \
    -R ${params.ref} \
    -V ${cohort_snp_recal_vcf} \
    -O cohort-snp-indel-recal-99.5.vcf.gz \
    --truth-sensitivity-filter-level 99.5 \
    --tranches-file indel_output.tranches \
    --recal-file indel_output.recal \
    -mode INDEL \
    2> vqsr_apply_indel-${params.gendb}.log
  """
}
