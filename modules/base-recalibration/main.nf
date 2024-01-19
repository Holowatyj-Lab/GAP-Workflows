/*
Build base recalibration model from BAM and apply it
*/
process BASE_RECAL {
  tag "$sample_id"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/reports",
    mode: "copy",
    pattern: "*.table"
  )

  publishDir(
    "${params.out}/bams",
    mode: "copy",
    pattern: "*.{bam,bai}"
  )

  input:
  tuple(
    val(sample_id),
    path(markdup_bam)
  )

  output:
  path "*.log"
  path "*.table"
  path "*.bai"
  tuple(
    val(sample_id),
    path("${sample_id}-markdup-bqsr.bam"),
    emit: markdup_bqsr_bam
  )

  """
  gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=2" BaseRecalibrator \
    -R ${params.ref} \
    -I ${markdup_bam} \
    -O baserecal_data-${sample_id}.table \
    --known-sites ${params.dbsnp} \
    --known-sites ${params.known_indels} \
    --known-sites ${params.mills} \
    2> baserecal-${sample_id}.log

  gatk --java-options "-Xms2G -Xmx2G -XX:ParallelGCThreads=2" ApplyBQSR \
    -R ${params.ref} \
    -I ${markdup_bam} \
    --bqsr-recal-file baserecal_data-${sample_id}.table \
    -O ${sample_id}-markdup-bqsr.bam \
    2> apply_bqsr-${sample_id}.log
  """
}