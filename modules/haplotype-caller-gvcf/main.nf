/*
Runs GATK HaplotypeCaller in GVCF mode for individual BAM files
*/
process HAPLOTYPE_CALLER_GVCF {
  tag "$sample_id"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/gvcfs",
    mode: "copy",
    pattern: "*.g.vcf.*"
  )

  input:
  tuple(
    val(sample_id),
    path(markdup_bqsr_bam)
  )

  output:
  path "*.log"
  tuple(val(sample_id), path("${sample_id}.g.vcf.gz"), path("${sample_id}.g.vcf.gz.tbi"), emit: gvcf)

  script:
  interval_params = params.intervals ? "-L ${params.intervals} -ip 50" : ""
  
  """
  gatk --java-options "-Xms20G -Xmx20G -XX:ParallelGCThreads=2" HaplotypeCaller \
    -R ${params.ref} \
    -I ${markdup_bqsr_bam} \
    ${interval_params} \
    -O ${sample_id}.g.vcf.gz \
    -ERC GVCF \
    2> haplotype_caller_gvcf-${sample_id}.log
  """
}