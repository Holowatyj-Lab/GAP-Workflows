/*
Builds a genomics database with the name set by the --gendb workflow parameter.
*/
process GENOMICS_DB_IMPORT {
  tag "$gendb"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    params.out,
    mode:"copy",
    pattern: "${gendb}"
  )

  input:
  tuple(
    val(sample_id),
    path(gvcf),
    path(gvcf_index),
    val(gendb)
  )

  output:
  path("*.log")
  path("${gendb}"), emit: gendb

  script:
  gvcf_params = gvcf.collect(){ "-V $it" }.join(' ')
  interval_params = params.intervals ? "--intervals ${params.intervals} --interval-padding 50 --merge-input-intervals true" : ""

  """
  gatk --java-options "-Xmx4g -Xms4g" GenomicsDBImport \
    -R ${params.ref} \
    --genomicsdb-workspace-path ${gendb} \
    ${gvcf_params} \
    --tmp-dir . \
    --max-num-intervals-to-import-in-parallel 4 \
    ${interval_params} \
    2> genomics_db_import-${gendb}.log
  """
}
