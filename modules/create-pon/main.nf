/*
Create a panel of normals from a genomics database input
*/
process CREATE_PON {
  tag "$gendb"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/pon",
    mode: "copy",
    pattern: "*.vcf*"
  )

  input:
  path(gendb)

  output:
  path("*.log")
  tuple(
    path("pon-${params.gendb}.vcf.gz"),
    path("pon-${params.gendb}.vcf.gz.tbi"),
    emit: pon_vcf
  )

  """
  gatk CreateSomaticPanelOfNormals \
    -R ${params.ref} \
    --germline-resource ${params.germline_resource} \
    -V gendb://${gendb} \
    -O pon-${params.gendb}.vcf.gz \
    2> create-pon-${params.gendb}.log
  """
}