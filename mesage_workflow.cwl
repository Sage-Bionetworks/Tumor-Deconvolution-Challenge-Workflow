#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

inputs:
  - id: annotation_string
    type: string
  - id: synapseConfig
    type: File

outputs:

  - id: body
    type: string
    outputSource: create_email_message/body

steps:

  - id: create_email_message
    run: create_email_message.cwl
    in:  
    - id: status
      valueFrom: "SCORED"
    - id: evaluation_name
      valueFrom: "queue"
    - id: submissionid
      valueFrom: $(1)
    - id: submission_name
      valueFrom: "sub_name"
    - id: invalid_reason_string
      valueFrom: ""
    - id: annotation_string
      source: annotation_string
    out: 
    - id: subject
    - id: body

  - id: send_message
    run: send_message.cwl
    in:  
    - id: synapse_config
      source: synapseConfig
    - id: userid
      valueFrom: "3360851"
    - id: body
      source: create_email_message/body
    - id: subject
      source: create_email_message/subject
    out: []

