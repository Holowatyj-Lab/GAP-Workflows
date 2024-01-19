/*
Preprocess raw FASTQs with fastp
*/
process FASTP {
  tag "$sample_id"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  publishDir(
    "${params.out}/reports",
    mode: "copy",
    pattern: "*.{html,json}"
  )

  input:
  tuple(
    val(sample_id),
    path(r1_path),
    path(r2_path)
  )

  output:
  path("*.log")
  path("*.{html,json}")
  tuple(
    val(sample_id),
    path("${sample_id}-fastp-R1.fastq.gz"),
    path("${sample_id}-fastp-R2.fastq.gz"),
    emit: processed_fastq
  )
  
  """
  fastp \
    --thread 2 \
    -i ${r1_path} \
    -I ${r2_path} \
    -o ${sample_id}-fastp-R1.fastq.gz \
    -O ${sample_id}-fastp-R2.fastq.gz \
    -h fastp-${sample_id}.html \
    -j fastp-${sample_id}.json \
    2> fastp-${sample_id}.log \
  """
}

