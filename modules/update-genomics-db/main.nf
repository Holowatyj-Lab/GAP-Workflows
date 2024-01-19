/*
Given a previously existing genomics database, update it by adding new samples
*/
process UPDATE_GENOMICS_DB {
  tag "$gendb"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    params.out,
    mode: "copy",
    pattern: "${gendb}"
  )

  input:
  tuple(
    val(sample_id),
    path(gvcf),
    path(gvcf_index),
    path(gendb)
  )

  output:
  path("*.log")
  path("${gendb}"), emit: gendb

  script:
  gvcf_params = gvcf.collect(){ "-V $it" }.join(' ')

  """
  gatk --java-options "-Xmx4g -Xms4g" GenomicsDBImport \
    -R ${params.ref} \
    --genomicsdb-update-workspace-path ${gendb} \
    ${gvcf_params} \
    --tmp-dir . \
    --max-num-intervals-to-import-in-parallel 4 \
    2> genomics_db_import-${gendb}.log
  """
}