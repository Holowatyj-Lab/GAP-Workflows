/*
Create read orientation model, get pileup summaries, calculate contamination, and filter Mutect2 calls
*/
process FILTER_MUTECT_CALLS {
  tag "$sample_id"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/reports",
    mode: "copy",
    pattern: "*.{tar.gz,table}"
  )

  publishDir(
    "${params.out}/mutect2/filtered",
    mode: "copy",
    pattern: "*.vcf*"
  )

  input:
  tuple(
    val(sample_id),
    path(mutect2_bam),
    path(mutect2_vcf),
    path(mutect2_vcf_index),
    path(f1r2),
    path(mutect2_stats)
  )

  output:
  path("*.log")
  tuple(
    val(sample_id),
    path("${sample_id}-mutect2-filtered.vcf"),
    path("${sample_id}-mutect2-filtered.vcf.idx")
  )

  """
  gatk LearnReadOrientationModel \
    -I ${f1r2} \
    -O ${sample_id}-read-orientation-model.tar.gz \
    2> learn-read-orientation-model-${sample_id}.log

  gatk GetPileupSummaries \
    -I ${mutect2_bam} \
    -V ${params.common_germline_variants} \
    -L ${params.common_germline_variants} \
    -O ${sample_id}-pileupsummaries.table \
    2> get-pileup-summaries-${sample_id}.log

  gatk CalculateContamination \
    -I ${sample_id}-pileupsummaries.table \
    --tumor-segmentation ${sample_id}-segments.table \
    -O ${sample_id}-contamination.table \
    2> calculate-contamination-${sample_id}.log

  gatk FilterMutectCalls \
    -R ${params.ref} \
    -V ${mutect2_vcf} \
    --tumor-segmentation ${sample_id}-segments.table \
    --contamination-table ${sample_id}-contamination.table \
    --ob-priors ${sample_id}-read-orientation-model.tar.gz \
    -O ${sample_id}-mutect2-filtered.vcf \
    2> filter-mutect-calls-${sample_id}.log
  """
}