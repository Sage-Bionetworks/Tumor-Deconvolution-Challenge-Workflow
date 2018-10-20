#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: [Rscript, /usr/local/bin/validate.R]

hints:
  DockerRequirement:
    dockerPull: quay.io/andrewelamb/tumor_deconvolution_challenge
    
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
      location: r2/gold_standard.csv

  json_file:
    type: string
    default: "results.json"
    inputBinding:
      position: 3

outputs:

  - id: results
    type: File
    outputBinding:
      glob: $(inputs.json_file)
      
  - id: status
    type: string
    outputBinding:
      glob: $(inputs.json_file)
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['predictionFileStatus'])

  - id: invalidReasons
    type: string
    outputBinding:
      glob: $(inputs.json_file)
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['predictionFileErrors'])
