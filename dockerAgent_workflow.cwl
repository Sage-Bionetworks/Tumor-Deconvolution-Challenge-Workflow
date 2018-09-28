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
  getSubmissionDocker:
    run: getSubmissionDocker.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: synapseConfig
        source: "#synapseConfig"
    out:
      - id: dockerRepository
      - id: dockerDigest
      - id: entityId
      
  validation:
    run: validateDocker.cwl
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

#  annotateValidationWithOutput:
#    run: annotateSubmission.cwl
#    in:
#      - id: submissionId
#        source: "#submissionId"
#      - id: annotationValues
#        source: "#validation/results"
#      - id: private
#        valueFrom: "false"
#      - id: synapseConfig
#        source: "#synapseConfig"
#    out: []
 
  getDockerConfig:
    run: getDockerConfig.cwl
    in:
      - id: synapseConfig
        source: "#synapseConfig"
    out: 
      - id: dockerRegistry
      - id: dockerAuth

  runDocker:
    run: runDocker.cwl
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
    out:
      - id: predictions

  uploadResults:
    run: uploadToSynapse.cwl
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