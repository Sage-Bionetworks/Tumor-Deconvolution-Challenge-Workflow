#!/usr/bin/env cwl-runner
#
# Authors: Andrew Lamb

cwlVersion: v1.0
class: ExpressionTool

requirements:
- class: InlineJavascriptRequirement

inputs:

- id: evaluationid
  type: string

outputs:

- id: name
  type: string
- id: gold_standard_id
  type: string
- id: docker_input_directory
  type: string
- id: score_submission
  type: boolean

expression: |

  ${
    var dict = {
      "9614257": {
        //Course_Fast_Lane
        gold_standard_id: "syn20071471",
        docker_input_directory: "/home/ubuntu/fast_lane_dir",
        score_submission: false
       },
      "9614252": {
        //Fine_Fast_Lane
        gold_standard_id: "syn20071476",
        docker_input_directory: "/home/ubuntu/fast_lane_dir",
        score_submission: false
       },
      "9614253": {
        //R1_Course
        gold_standard_id: "syn20564963",
        docker_input_directory: "/home/ubuntu/leaderboard1_dir",
        score_submission: true
       },
      "9614255": {
        //R1_Fine
        gold_standard_id: "syn20564965",
        docker_input_directory: "/home/ubuntu/leaderboard1_dir",
        score_submission: true
       }
    };
    return(dict[inputs.evaluationid])
  }

