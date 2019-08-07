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

- id: status
  type: string
- id: evaluation_name
  type: string
- id: submissionid
  type: int
- id: submission_name
  type: string
- id: invalid_reason_string
  type: string
- id: annotation_string
  type: string

outputs:

- id: body
  type: string
- id: subject
  type: string

expression: |

  ${
    var subject = "Submission to " + inputs.evaluation_name + " processed." 

    if(inputs.status == "VALIDATED"){
      var body = "Your submission is valid!"

    } else if(inputs.status == "INVALID"){
      var body = "Your submission is invalid, below are the reason(s):\n\n" +
                 inputs.invalid_reason_string

    } else {
      var body = "Your submission has been scored, below are your result(s):\n\n" +
                 inputs.annotation_string.split(";").join("\n").split(":").join(" ") +
                 "\n\n\n"

    }
    body = "Hello participant,\n\n" +
              body +
              "\nSubmission ID: " + 
              inputs.submissionid +
              "\nSubmission name: " + 
              inputs.submission_name +
              "\n\n\nSincerely," +
              "\nChallenge Administrator"
              
    return {body: body, subject: subject}
  }
