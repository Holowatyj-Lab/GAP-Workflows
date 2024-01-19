/*
Joint genotype a database of germline samples
*/
process GENOTYPE_GVCFS {
  tag "$gendb"
  
  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/cohort-vcfs",
    mode: "copy",
    pattern: "*.vcf*"
  )

  input:
  path(gendb)

  output:
  path("*.log")
  tuple(
    path("cohort-${params.gendb}.vcf.gz"),
    path("cohort-${params.gendb}.vcf.gz.tbi"),
    emit: cohort_vcf
  )

  """
  gatk --java-options "-Xmx4G -XX:ParallelGCThreads=2" GenotypeGVCFs \
    -R ${params.ref} \
    -V gendb://${gendb} \
    -O cohort-${params.gendb}.vcf.gz \
    2> genotype_gvcfs-${params.gendb}.log
  """
}