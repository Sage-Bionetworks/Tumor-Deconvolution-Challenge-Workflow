#!/usr/bin/env cwl-runner
#
# Sample workflow
# Inputs:
#   submissionId: ID of the Synapse submission to process
#   adminUploadSynId: ID of a folder accessible only to the submission queue administrator
#   submitterUploadSynId: ID of a folder accessible to the submitter
#   workflowSynapseId:  ID of the Synapse entity containing a reference to the workflow file(s)
#   synapseConfig: ~/.synapseConfig file that has your Synapse credentials
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
  downloadSubmission:
    run: downloadSubmissionFile.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: synapseConfig
        source: "#synapseConfig"
    out:
      - id: filePath
      - id: entity
      
  validation:
    run: validate_r1.cwl
    in:
      - id: inputfile
        source: "#downloadSubmission/filePath"
    out:
      - id: results
      - id: status
      - id: invalidReasons
  
  validationEmail:
    run: validationEmail.cwl
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
    run: annotateSubmission.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: annotationValues
        source: "#validation/results"
      - id: private
        valueFrom: "false"
      - id: synapseConfig
        source: "#synapseConfig"
    out: []

  scoring:
    run: score_r1.cwl
    in:
      - id: inputfile
        source: "#downloadSubmission/filePath"
      - id: status 
        source: "#validation/status"
    out:
      - id: results
      
  scoreEmail:
    run: scoreEmail.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: synapseConfig
        source: "#synapseConfig"
      - id: results
        source: "#scoring/results"
    out: []

  annotateSubmissionWithOutput:
    run: annotateSubmission.cwl
    in:
      - id: submissionId
        source: "#submissionId"
      - id: annotationValues
        source: "#scoring/results"
      - id: private
        valueFrom: "false"
      - id: synapseConfig
        source: "#synapseConfig"
    out: []
 