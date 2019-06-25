#!/usr/bin/env cwl-runner

$namespaces:
  s: https://schema.org/

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-0326-7494
    s:email: andrew.lamb@sagebase.org

s:name: Andrew Lamb

cwlVersion: v1.0
class: ExpressionTool

requirements:
- class: InlineJavascriptRequirement

inputs:

- id: input_file
  type: File
- id: new_file_name
  type: string

outputs:

- id: output_file
  type: File

expression: |
  ${
    inputs.input_file.basename = inputs.new_file_name;
    return {output_file: inputs.input_file};
  }
