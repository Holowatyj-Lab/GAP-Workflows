/*
Align to reference genome with BWA MEM and sort with samtools.
*/
process BWA_MEM {
  tag "$sample_id"

  publishDir(
    "${params.out}/logs",
    mode: "copy",
    pattern: "*.log"
  )

  input:
  tuple(
    val(sample_id),
    path(r1_path),
    path(r2_path)
  )

  output:
  path("*.log")
  tuple(
    val(sample_id),
    path("${sample_id}.bam"),
    emit: bam
  )
  
  """
  # Create read group information for each sample
  sample_num=${sample_id}

  fastq_header=\$(zcat ${r1_path} | head -n 1)
  # e.g. @A00252:291:H2KJTDSX5:1:1101:20961:1000 1:N:0:TATCTTCAGC+CGAATATTGG

  flowcell_id=\$(echo \${fastq_header} | awk -F ':' '{print \$3}')
  lane=\$(echo \${fastq_header} | awk -F ':' '{print \$4}')

  read_group=\$(echo "@RG\\tID:\$flowcell_id.${sample_id}.\$lane\\tSM:${sample_id}\\tPL:illumina\\tLB:twist-exome\\tPU:\$flowcell_id.\$lane")
  # e.g. @RG\tID:H2KJTDSX5.0001.1\tSM:0001\tPL:illumina\tLB:twist-exome\tPU:H2KJTDSX5.1

  bwa mem \
    -M \
    -t 32 \
    -R \$read_group \
    ${params.ref} \
    ${r1_path} \
    ${r2_path} \
    2> bwa-${sample_id}.log \
  | samtools sort \
    -T ${sample_id}-samtools-tmp \
    -@ 32 \
    -O BAM \
    -o ${sample_id}.bam \
    2> samtools-${sample_id}.log
  """
}