
include { ALIGN } from './subworkflows/align'
include { JOINT_CALL } from './subworkflows/joint-call'
include { MAKE_PON } from './subworkflows/make-pon'
include { SOMATIC_CALL } from './subworkflows/somatic-call'

log.info """\n
  ____    _    ____                               
 / ___|  / \\  |  _ \\                              
| |  _  / _ \\ | |_) |                             
| |_| |/ ___ \\|  __/                              
_\\____/_/ __\\_\\_|    _     __ _                   
\\ \\      / /__  _ __| | __/ _| | _____      _____ 
 \\ \\ /\\ / / _ \\| '__| |/ / |_| |/ _ \\ \\ /\\ / / __|
  \\ V  V / (_) | |  |   <|  _| | (_) \\ V  V /\\__ \\
   \\_/\\_/ \\___/|_|  |_|\\_\\_| |_|\\___/ \\_/\\_/ |___/

R E F E R E N C E  D A T A
==========================
Reference Genome:
  ${params.ref}
  
Additional Reference Files:
  ${params.dbsnp ? params.dbsnp : ""}
  ${params.known_indels ? params.known_indels : ""}
  ${params.mills ? params.mills : ""}
  ${params.hapmap ? params.hapmap : ""}
  ${params.omni ? params.omni : ""}
  ${params.phase1 ? params.phase1 : ""}
  ${params.germline_resource ? params.germline_resource : ""}
  ${params.common_germline_variants ? params.common_germline_variants : ""}

S U B W O R K F L O W   O P T I O N S
=====================================
--samples=${params.samples}
  <PATH> path to sample sheet CSV

--input=${params.input}
  <STRING> input file type (options: fastq, bam)

--subworkflow=${params.subworkflow}
  <STRING> subworkflow (options: joint-call, somatic-call, make-pon)

--out=${params.out}
  <STRING> name of outputs directory

--pon=${params.pon}
  <PATH> path to panel of normals; used in somatic-call subworkflow

--gendb=${params.gendb}
  <STRING> name of new genomics database; used in joint-call and make-pon subworkflow

--updategendb=${params.updategendb}
  <PATH> path to existing genomics database; used when adding a new sample to genomicsdb in joint-call or make-pon subworkflow

--paired=${params.paired}
  <BOOLEAN> determines if somatic-caller subworkflow is run with a paired normal
"""
.stripIndent()

workflow {
  Channel
    .fromPath(params.samples)
    .splitCsv(header: false)
    .set { sample_ch }

  bam_ch = Channel.empty()

  if (params.input == "fastq") {
    ALIGN(sample_ch)
    bam_ch = ALIGN.out
  } else if (params.input == "bam") {
    bam_ch = sample_ch
  } else {
    println "Specify valid input file type (fastq, bam). \n"
  }

  if (params.subworkflow == "joint-call") {
    JOINT_CALL(bam_ch)
  } else if (params.subworkflow == "make-pon") {
    MAKE_PON(bam_ch)
  } else if (params.subworkflow == "somatic-call") {
    SOMATIC_CALL(bam_ch)
  }
}