/*
Mark duplicates; optical pixel distance set to 2500 by default
*/
process MARK_DUPLICATES {
  tag "$sample_id"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/reports",
    mode: "copy",
    pattern: "*.txt"
  )

  input:
  tuple(
    val(sample_id),
    path(bam)
  )

  output:
  path("*.log")
  path("*.txt")
  tuple(
    val(sample_id),
    path("${sample_id}-markdup.bam"),
    emit: markdup_bam
  )

  """
  gatk --java-options "-Xmx64G" MarkDuplicatesSpark \
    -I ${bam} \
    -O ${sample_id}-markdup.bam \
    -M markdups-metrics-${sample_id}.txt \
    --optical-duplicate-pixel-distance 2500 \
    --spark-master local[12] \
    --tmp-dir . \
    2> markdups-${sample_id}.log
  """
}