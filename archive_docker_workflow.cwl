#!/usr/bin/env cwl-runner
#
# Main workflow.  Runs through synthetic data and submits to internal queue
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
  create_adminsynid_json:
    run: create_adminsynid_annotation.cwl
    in:
      - id: admin_synid
        source: "#adminUploadSynId"
    out: [json_out]

  annotate_adminsynid:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v2.5/annotate_submission.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: annotation_values
        source: "#create_adminsynid_json/json_out"
      - id: to_public
        default: true
      - id: force_change_annotation_acl
        default: true
      - id: synapse_config
        source: "#synapseConfig"
    out: [finished]

  set_permissions:
    run:  https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v2.5/set_permissions.cwl
    in:
      - id: entityid
        source: "#submitterUploadSynId"
      - id: principalid
        valueFrom: "3407544"
      - id: permissions
        valueFrom: "download"
      - id: synapse_config
        source: "#synapseConfig"
    out: []

  get_docker_submission:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v2.5/get_submission.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: synapse_config
        source: "#synapseConfig"
    out:
      - id: filepath
      - id: docker_repository
      - id: docker_digest
      - id: entity_id
      - id: entity_type
      - id: results
      
  validate_json:
    run: validate_main_submission.cwl
    in:
      - id: submission
        source: "#get_docker_submission/filepath"
      - id: synapse_config
        source: "#synapseConfig"
    out:
      - id: results
      - id: status
      - id: invalid_reasons
      - id: docker_repository
      - id: docker_digest

  check_status:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v2.5/check_status.cwl
    in:
      - id: status
        source: "#validate_json/status"
      - id: previous_annotation_finished
        source: "#annotate_docker_validation_with_output/finished"
      - id: previous_email_finished
        source: "#validate_json_email/finished"
    out: [finished]

  get_docker_config:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v2.5/get_docker_config.cwl
    in:
      - id: synapse_config
        source: "#synapseConfig"
    out: 
      - id: docker_registry
      - id: docker_authentication
  
  archive_docker:
    run: archive_docker.cwl
    in:
      - id: previous_step
        source: "#check_status/finished"
      - id: docker_repository
        source: "#validate_json/docker_repository"
      - id: docker_digest
        source: "#validate_json/docker_digest"
      - id: submissionid
        source: "#submissionId"
      - id: docker_registry
        source: "#get_docker_config/docker_registry"
      - id: docker_authentication
        source: "#get_docker_config/docker_authentication"
      - id: status
        source: "#validate_json/status"
      #- id: parentid
      #  valueFrom: "syn21905730"
      - id: synapse_config
        source: "#synapseConfig"
    out:
      - id: results
      - id: archived_docker

