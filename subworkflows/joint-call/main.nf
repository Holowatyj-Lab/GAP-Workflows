
include { HAPLOTYPE_CALLER_GVCF } from '../../modules/haplotype-caller-gvcf'
include { GENOMICS_DB_IMPORT } from '../../modules/genomics-db-import'
include { UPDATE_GENOMICS_DB } from '../../modules/update-genomics-db' 
include { GENOTYPE_GVCFS } from '../../modules/genotype-gvcfs'
include { VQSR_SNP } from '../../modules/vqsr-snp'
include { VQSR_INDEL } from '../../modules/vqsr-indel'

workflow JOINT_CALL {
  take:
  bam // [sample_id, bam]

  main:
  HAPLOTYPE_CALLER_GVCF(bam)

  if (params.updategendb) {
    UPDATE_GENOMICS_DB(
      HAPLOTYPE_CALLER_GVCF.out.gvcf
        .map{ sample_id, gvcf, gvcf_index -> [sample_id, gvcf, gvcf_index, params.updategendb] }
        .groupTuple(by:3)
    )
    
    GENOTYPE_GVCFS(UPDATE_GENOMICS_DB.out.gendb)
  } else {
    GENOMICS_DB_IMPORT(
      HAPLOTYPE_CALLER_GVCF.out.gvcf
        .map{ sample_id, gvcf, gvcf_index -> [sample_id, gvcf, gvcf_index, params.gendb] }
        .groupTuple(by:3)
    )

    GENOTYPE_GVCFS(GENOMICS_DB_IMPORT.out.gendb)
  }

  VQSR_SNP(GENOTYPE_GVCFS.out.cohort_vcf)
  VQSR_INDEL(VQSR_SNP.out.cohort_snp_recal_vcf)
}