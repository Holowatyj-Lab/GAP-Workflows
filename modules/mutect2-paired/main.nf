/*
Run Mutect2 in paired tumor-normal mode to find potential somatic mutations
*/
process MUTECT2_PAIRED {
  tag "$sample_id"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/reports",
    mode: "copy",
    pattern: "*.{tar.gz,stats}"
  )

  publishDir(
    "${params.out}/mutect2/unfiltered",
    mode: "copy",
    pattern: "*.vcf*"
  )

  input:
  tuple(
    val(sample_id),
    path(tumor_bam),
    path(normal_bam)
  )

  output:
  path("*.log")
  tuple(
    val(sample_id),
    path(tumor_bam),
    path("${sample_id}-mutect2.vcf.gz"),
    path("${sample_id}-mutect2.vcf.gz.tbi"),
    path("${sample_id}-f1r2.tar.gz"),
    path("${sample_id}-mutect2.vcf.gz.stats"),
    emit: mutect2_vcf
  )
  
  script:
  interval_params = params.intervals ? "-L ${params.intervals} -ip 50" : ""
  pon_params = params.pon ? "-pon ${params.pon}" : ""

  """
  gatk GetSampleName \
    -encode \
    -I ${normal_bam} \
    -O normal_name.txt

  normal_name=\$(<normal_name.txt)

  gatk Mutect2 \
    -R ${params.ref} \
    ${interval_params} \
    -I ${tumor_bam} \
    -I ${normal_bam} \
    -normal \${normal_name} \
    --germline-resource ${params.germline_resource} \
    ${pon_params} \
    --f1r2-tar-gz ${sample_id}-f1r2.tar.gz \
    -O ${sample_id}-mutect2.vcf.gz \
    2> mutect2-${sample_id}.log
  """
  }
