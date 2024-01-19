
include { FASTP } from '../../modules/fastp' 
include { BWA_MEM } from '../../modules/bwa-mem'
include { MARK_DUPLICATES } from '../../modules/mark-duplicates'
include { BASE_RECAL } from '../../modules/base-recalibration'

workflow ALIGN {
  take:
  sample // [sample_id, read_1, read_2]

  main:
  FASTP(sample)
  BWA_MEM(FASTP.out.processed_fastq)
  MARK_DUPLICATES(BWA_MEM.out.bam)
  BASE_RECAL(MARK_DUPLICATES.out.markdup_bam)

  emit:
  BASE_RECAL.out.markdup_bqsr_bam
}