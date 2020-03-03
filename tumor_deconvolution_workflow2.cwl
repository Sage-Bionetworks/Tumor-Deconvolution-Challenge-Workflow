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
    default: "syn21576615"
  - id: submitterUploadSynId
    type: string
    default: "syn21576615"
  - id: workflowSynapseId
    type: string
    default: ""
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
    run: get_evaluation_parameters2.cwl
    in:
      - id: evaluationid
        source: get_submission_attributes/evaluationid
    out:
      - id: gold_standard_id
      - id: docker_input_directory
      - id: docker_param_directory
      - id: score_submission
      - id: cores
      - id: ram

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
      - id: cores
        source: get_evaluation_parameters/cores
      - id: ram
        source: get_evaluation_parameters/ram
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
      - id: param_dir
        source: get_evaluation_parameters/docker_param_directory
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

