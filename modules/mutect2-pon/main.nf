/*
Run Mutect2 on germline normal samples to build a panel of normals
*/
process MUTECT2_PON {
  tag "$sample_id"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  input:
  tuple(
    val(sample_id),
    path(markdup_bqsr_bam)
  )

  output:
  path("*.log")
  tuple(
    val(sample_id),
    path("${sample_id}-mutect2-pon.vcf.gz"),
    path("${sample_id}-mutect2-pon.vcf.gz.tbi"),
    emit: mutect2_pon_vcf
  )

  script:
  interval_params = params.intervals ? "-L ${params.intervals} -ip 50" : ""

  """
  gatk Mutect2 \
    -R ${params.ref} \
    -I ${markdup_bqsr_bam} \
    ${intervals_params} \
    --max-mnp-distance 0 \
    -O ${sample_id}-mutect2-pon.vcf.gz \
    2> mutect2-pon-${sample_id}.log
  """
}