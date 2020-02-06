#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  - id: submissionIds
    type: int[]
  - id: synapseConfig
    type: File
  - id: submission_file_ids
    type: string[]


outputs: []

steps:

  - id: process_submissions
    run: tumor_deconvolution_process_workflow.cwl
    in:
      - id: submissionId
        source: submissionIds
      - id: synapseConfig
        source: synapseConfig
      - id: submission_file_id
        source: submission_file_ids
    scatter:
      - submissionId
      - submission_file_id
    scatterMethod: dotproduct
    out: []
