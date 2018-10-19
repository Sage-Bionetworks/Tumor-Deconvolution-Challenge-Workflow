#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [Rscript, /usr/local/bin/score.R]

hints:
  DockerRequirement:
    dockerPull: tumor_deconvolution_challenge
    
requirements:
  - class: InlineJavascriptRequirement

inputs:

  inputfile:
    type: File
    inputBinding:
      position: 1
  
  validation_file:
    type: File
    inputBinding:
      position: 2
    default:
      class: File
      location: example_files/validation_rd1.csv

  json_file:
    type: string
    default: "results.json"
    inputBinding:
      position: 3
      
  status:
    type: string
    inputBinding:
      position: 4

outputs:

  - id: results
    type: File
    outputBinding:
      glob: $(inputs.json_file)