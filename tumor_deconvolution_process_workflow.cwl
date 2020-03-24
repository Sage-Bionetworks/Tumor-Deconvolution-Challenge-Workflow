#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

inputs:
  - id: submissionId
    type: int
  - id: synapseConfig
    type: File
  - id: submission_file_id
    type: string


outputs:
 
- id: file
  type: File
  outputSource: process_prediction_file/annotation_json
  

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

  - id: download_goldstandard
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/v0.1/synapse-get-tool.cwl
    in:
    - id: synapseid
      source: get_evaluation_parameters/gold_standard_id
    - id: synapse_config
      source: synapseConfig
    out:
    - id: filepath

  - id: download_submission
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/v0.1/synapse-get-tool.cwl
    in:
    - id: synapseid
      source: submission_file_id
    - id: synapse_config
      source: synapseConfig
    out:
    - id: filepath

  - id: process_prediction_file
    run: process_prediction_file2.cwl
    in: 
    - id: submission_file
      source: download_submission/filepath
    - id: validation_file
      source: download_goldstandard/filepath
    - id: score_submission
      source: get_evaluation_parameters/score_submission
    - id: fail_missing
      valueFrom: $(false)
    out:
    - id: annotation_json

#  - id: annotate_submission
#    run: https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v2.3/annotate_submissio#n.cwl
#    in:
#      - id: submissionid
#        source: submissionId
#      - id: annotation_values
#        source: process_prediction_file/annotation_json
#      - id: to_public
#        valueFrom: $(true)
#      - id: force_change_annotation_acl
#        valueFrom: $(true)
#      - id: synapse_config
#        source: synapseConfig
#    out: []
    




