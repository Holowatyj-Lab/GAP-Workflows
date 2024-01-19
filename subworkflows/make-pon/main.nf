
include { MUTECT2_PON } from '../../modules/mutect2-pon'
include { GENOMICS_DB_IMPORT } from '../../modules/genomics-db-import'
include { UPDATE_GENOMICS_DB } from '../../modules/update-genomics-db'
include { CREATE_PON } from '../../modules/create-pon'

workflow MAKE_PON {
  take:
  bam // [sample_id, bam]

  main:
  MUTECT2_PON(bam)

  if (params.updategendb) {
    UPDATE_GENOMICS_DB(
      MUTECT2_PON.out.mutect2_pon_vcf
        .map{ sample_id, mutect2_pon_vcf, mutect2_pon_vcf_index -> [sample_id, mutect2_pon_vcf, mutect2_pon_vcf_index, params.updategendb] }
        .groupTuple(by:3)
    )
    
    CREATE_PON(UPDATE_GENOMICS_DB.out.gendb)
  } else {
    GENOMICS_DB_IMPORT(
      MUTECT2_PON.out.mutect2_pon_vcf
        .map{ sample_id, mutect2_pon_vcf, mutect2_pon_vcf_index -> [sample_id, mutect2_pon_vcf, mutect2_pon_vcf_index, params.gendb] }
        .groupTuple(by:3)
    )

    CREATE_PON(GENOMICS_DB_IMPORT.out.gendb)
  }
}
