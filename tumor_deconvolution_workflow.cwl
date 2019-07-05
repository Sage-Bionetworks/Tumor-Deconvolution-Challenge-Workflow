#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

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

outputs: []

steps:

  - id: get_submission_attributes
    run: get_submission_attributes.cwl
    in:
      - id: submissionid
        source: submissionId
      - id: synapse_config
        source: synapseConfig
    out:
      - id: userid
      - id: name
      - id: evaluationid

  - id: get_evaluation_attributes
    run: get_evaluation_attributes.cwl
    in:
      - id: evaluationid
        source: get_submission_attributes/evaluationid
      - id: synapse_config
        source: synapseConfig
    out:
      - id: name

  - id: get_evaluation_parameters
    run: get_evaluation_parameters.cwl
    in:
      - id: evaluationid
        source: get_submission_attributes/evaluationid
    out:
      - id: gold_standard_id
      - id: docker_input_directory
      - id: score_submission

  - id: get_docker_submission
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v1.5/get_submission_docker.cwl
    in:
      - id: submissionid
        source: submissionId
      - id: synapse_config
        source: synapseConfig
    out:
      - id: docker_repository
      - id: docker_digest
      - id: entityid

  - id: validate_docker
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v1.5/validate_docker.cwl
    in:
      - id: docker_repository
        source: get_docker_submission/docker_repository
      - id: docker_digest
        source: get_docker_submission/docker_digest
      - id: synapse_config
        source: synapseConfig
    out:
      - id: results
      - id: status
      - id: invalid_reasons

  - id: annotate_docker_validation_with_output
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v1.5/annotate_submission.cwl
    in:
      - id: submissionid
        source: submissionId
      - id: annotation_values
        source: validate_docker/results
      - id: to_public
        valueFrom: "true"
      - id: force_change_annotation_acl
        valueFrom: "true"
      - id: synapse_config
        source: synapseConfig
    out: []

  - id: get_docker_config
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v1.5/get_docker_config.cwl
    in:
      - id: synapse_config
        source: synapseConfig
    out: 
      - id: docker_registry
      - id: docker_authentication


  - id: run_docker
    run: run_docker.cwl
    in:
      - id: docker_repository
        source: get_docker_submission/docker_repository
      - id: docker_digest
        source: get_docker_submission/docker_digest
      - id: submissionid
        source: submissionId
      - id: docker_registry
        source: get_docker_config/docker_registry
      - id: docker_authentication
        source: get_docker_config/docker_authentication
      - id: status
        source: validate_docker/status
      - id: parentid
        source: submitterUploadSynId
      - id: synapse_config
        source: synapseConfig
      - id: input_dir
        source: get_evaluation_parameters/docker_input_directory
    out:
      - id: predictions

  - id: rename_prediction_file
    run: rename_file.cwl
    in: 
    - id: input_file
      source: run_docker/predictions
    - id: new_file_name
      source: submissionId
      valueFrom: $(self + ".csv")
    out:
    - id: output_file

  - id: store_prediction_file
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/v0.1/synapse-store-tool.cwl
    in: 
    - id: synapse_config
      source: synapseConfig
    - id: file_to_store
      source: rename_prediction_file/output_file
    - id: parentid
      valueFrom: "syn19518404"
    out: []

  - id: download_goldstandard
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/v0.1/synapse-get-tool.cwl
    in:
    - id: synapseid
      source: get_evaluation_parameters/gold_standard_id
    - id: synapse_config
      source: synapseConfig
    out:
    - id: filepath

  - id: process_prediction_file
    run: process_prediction_file.cwl
    in: 
    - id: submission_file
      source: run_docker/predictions
    - id: validation_file
      source: download_goldstandard/filepath
    - id: score_submission
      source: get_evaluation_parameters/score_submission
    out:
    - id: annotation_json
    - id: status
    - id: annotation_string
    - id: invalid_reason_string

  - id: annotate_submission
    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v1.5/annotate_submission.cwl
    in:
      - id: submissionid
        source: submissionId
      - id: annotation_values
        source: process_prediction_file/annotation_json
      - id: to_public
        valueFrom: "true"
      - id: force_change_annotation_acl
        valueFrom: "true"
      - id: synapse_config
        source: synapseConfig
    out: []

  - id: create_email_message
    run: create_email_message.cwl
    in:  
    - id: status
      source: process_prediction_file/status
    - id: evaluation_name
      source: get_evaluation_attributes/name
    - id: submissionid
      source: submissionId
    - id: submission_name
      source: get_submission_attributes/name
    - id: invalid_reason_string
      source: process_prediction_file/invalid_reason_string
    - id: annotation_string
      source: process_prediction_file/annotation_string
    out: 
    - id: subject
    - id: body

  - id: send_message
    run: send_message.cwl
    in:  
    - id: synapse_config
      source: synapseConfig
    - id: userid
      source: get_submission_attributes/userid
    - id: body
      source: create_email_message/body
    - id: subject
      source: create_email_message/subject
    out: []

