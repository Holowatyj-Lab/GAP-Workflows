
include { MUTECT2_PAIRED } from '../../modules/mutect2-paired'
include { MUTECT2_TUMOR_ONLY } from '../../modules/mutect2-tumor-only'
include { FILTER_MUTECT_CALLS } from '../../modules/filter-mutect-calls'

workflow SOMATIC_CALL {
  take:
  bam // [sample_id, bam, bam?]

  main:
  bam
    .branch {
      tumor_only: it.size() == 2
      tumor_normal: it.size() == 3
    }
    .set { bam }

  if (params.paired) {
    MUTECT2_PAIRED(bam.tumor_normal)
    FILTER_MUTECT_CALLS(MUTECT2_PAIRED.out.mutect2_vcf)
  } else {
    MUTECT2_TUMOR_ONLY(bam.tumor_only)  
    FILTER_MUTECT_CALLS(MUTECT2_TUMOR_ONLY.out.mutect2_vcf)
  }
}