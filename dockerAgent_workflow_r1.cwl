#!/usr/bin/env cwl-runner
#
# Sample workflow
# Inputs:
#   submissionId: ID of the Synapse submission to process
#   adminUploadSynId: ID of a folder accessible only to the submission queue administrator
#   submitterUploadSynId: ID of a folder accessible to the submitter
#   workflowSynapseId:  ID of the Synapse entity containing a reference to the workflow file(s)
#
cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement

inputs:
  - id: submissionId
    type: int
  - id: adminUploadSynId
    type: string
  - id: submitterUploadSynId
    type: string
  - id: workflowSynapseId
    type: string
  - id: synapseConfig
    type: File

# there are no output at the workflow engine level.  Everything is uploaded to Synapse
outputs: []

steps:

  downloadGoldStandard:
    run: downloadGoldStandard.cwl
    in:
      - id: synapseConfig
        source: "#synapseConfig"
# change to real gold standard
      - id: synapseId
        valueFrom: syn17015321
    out:
      - id: filePath

  getSubmissionDocker:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/getSubmissionDocker.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: synapseConfig
        source: "#synapseConfig"
    out:
      - id: dockerRepository
      - id: dockerDigest
      - id: entityId
      
  validateDocker:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/validateDocker.cwl
    in:
      - id: dockerRepository
        source: "#getSubmissionDocker/dockerRepository"
      - id: dockerDigest
        source: "#getSubmissionDocker/dockerDigest"
      - id: synapseConfig
        source: "#synapseConfig"
    out:
      - id: results
      - id: status
      - id: invalidReasons

  annotateValidationDockerWithOutput:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/annotateSubmission.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: annotationValues
        source: "#validateDocker/results"
      - id: toPublic
        valueFrom: "true"
      - id: forceChangeStatAcl
        valueFrom: "true"
      - id: synapseConfig
        source: "#synapseConfig"
    out: []
 
  getDockerConfig:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/getDockerConfig.cwl
    in:
      - id: synapseConfig
        source: "#synapseConfig"
    out: 
      - id: dockerRegistry
      - id: dockerAuth

  runDocker:
    run: runDocker_r1.cwl
    in:
      - id: dockerRepository
        source: "#getSubmissionDocker/dockerRepository"
      - id: dockerDigest
        source: "#getSubmissionDocker/dockerDigest"
      - id: submissionId
        source: "#submissionId"
      - id: dockerRegistry
        source: "#getDockerConfig/dockerRegistry"
      - id: dockerAuth
        source: "#getDockerConfig/dockerAuth"
      - id: status
        source: "#validateDocker/status"
      - id: parentId
        source: "#submitterUploadSynId"
      - id: synapseConfig
        source: "#synapseConfig"
    out:
     - id: predictions

  uploadResults:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/uploadToSynapse.cwl
    in:
      - id: infile
        source: "#runDocker/predictions"
      - id: parentId
        source: "#submitterUploadSynId"
      - id: usedEntity
        source: "#getSubmissionDocker/entityId"
      - id: executedEntity
        source: "#workflowSynapseId"
      - id: synapseConfig
        source: "#synapseConfig"
    out:
      - id: uploadedFileId
      - id: uploadedFileVersion
      - id: results

  annotateDockerUploadResults:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/annotateSubmission.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: annotationValues
        source: "#uploadResults/results"
      - id: toPublic
        valueFrom: "true"
      - id: forceChangeStatAcl
        valueFrom: "true"
      - id: synapseConfig
        source: "#synapseConfig"
    out: []

  validation:
    run: validate.cwl
    in:
      - id: inputfile
        source: "#runDocker/predictions"
      - id: validationFile
        source: "#downloadGoldStandard/filePath"
    out:
      - id: results
      - id: status
      - id: invalidReasons
  
  validationEmail:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/validationEmail.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: synapseConfig
        source: "#synapseConfig"
      - id: status
        source: "#validation/status"
      - id: invalidReasons
        source: "#validation/invalidReasons"

    out: []

  annotateValidationWithOutput:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/annotateSubmission.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: annotationValues
        source: "#validation/results"
      - id: toPublic
        valueFrom: "true"
      - id: forceChangeStatAcl
        valueFrom: "true"
      - id: synapseConfig
        source: "#synapseConfig"
    out: []

  scoring:
    run: score.cwl
    in:
      - id: inputfile
        source: "#runDocker/predictions"
      - id: validationFile
        source: "#downloadGoldStandard/filePath"
      - id: status 
        source: "#validation/status"
    out:
      - id: results
      
  scoreEmail:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/scoreEmail.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: synapseConfig
        source: "#synapseConfig"
      - id: results
        source: "#scoring/results"
    out: []

  annotateSubmissionWithOutput:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/master/annotateSubmission.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: annotationValues
        source: "#scoring/results"
      - id: toPublic
        valueFrom: "true"
      - id: forceChangeStatAcl
        valueFrom: "true"
      - id: synapseConfig
        source: "#synapseConfig"
    out: []
 
