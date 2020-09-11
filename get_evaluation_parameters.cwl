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
- id: docker_param_directory
  type: string
- id: score_submission
  type: boolean
- id: cores
  type: int
- id: ram
  type: int


expression: |

  ${
    var dict = {
      "9614257": {
        //Coarse_Fast_Lane
        gold_standard_id: "syn20071471",
        docker_input_directory: "/home/ubuntu/fast_lane_dir",
        docker_param_directory: "/home/ubuntu/fast_lane_coarse_dir",
        score_submission: false,
        cores: 4,
        ram: 15000
       },
      "9614252": {
        //Fine_Fast_Lane
        gold_standard_id: "syn20071476",
        docker_input_directory: "/home/ubuntu/fast_lane_dir",
        docker_param_directory: "/home/ubuntu/fast_lane_fine_dir",
        score_submission: false,
        cores: 4,
        ram: 15000
       },
      "9614253": {
        //R1_Coarse
        gold_standard_id: "syn20564963",
        docker_input_directory: "/home/ubuntu/leaderboard1_dir",
        docker_param_directory: "/home/ubuntu/leaderboard1_coarse_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614255": {
        //R1_Fine
        gold_standard_id: "syn20564965",
        docker_input_directory: "/home/ubuntu/leaderboard1_dir",
        docker_param_directory: "/home/ubuntu/leaderboard1_fine_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614313": {
        //R2_Coarse
        gold_standard_id: "syn20564964",
        docker_input_directory: "/home/ubuntu/leaderboard2_dir",
        docker_param_directory: "/home/ubuntu/leaderboard2_coarse_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614314": {
        //R2_Fine
        gold_standard_id: "syn20564966",
        docker_input_directory: "/home/ubuntu/leaderboard2_dir",
        docker_param_directory: "/home/ubuntu/leaderboard2_fine_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614315": {
        //R3_Coarse
        gold_standard_id: "syn20968872",
        docker_input_directory: "/home/ubuntu/leaderboard3_coarse_dir",
        docker_param_directory: "/home/ubuntu/leaderboard3_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614316": {
        //R3_Fine
        gold_standard_id: "syn20968867",
        docker_input_directory: "/home/ubuntu/leaderboard3_fine_dir",
        docker_param_directory: "/home/ubuntu/leaderboard3_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614317": {
        //Final_Coarse
        gold_standard_id: "syn21820375",
        docker_input_directory: "/home/ubuntu/validation_dir",
        docker_param_directory: "/home/ubuntu/validation_coarse_param_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614318": {
        //Final_Fine
        gold_standard_id: "syn21820376",
        docker_input_directory: "/home/ubuntu/validation_dir",
        docker_param_directory: "/home/ubuntu/validation_fine_param_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614582": {
        //Post_Final_Coarse
        gold_standard_id: "syn22267267",
        docker_input_directory: "/home/ubuntu/validation_dir",
        docker_param_directory: "/home/ubuntu/validation_coarse_param_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614583": {
        //Post_Final_Fine
        gold_standard_id: "syn21820376",
        docker_input_directory: "/home/ubuntu/validation_dir",
        docker_param_directory: "/home/ubuntu/validation_fine_param_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       }
      "9614614": {
        //Post_Final_Coarse2
        gold_standard_id: "syn21752552",
        docker_input_directory: "/home/ubuntu/validation_dir",
        docker_param_directory: "/home/ubuntu/validation_coarse_param_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       },
      "9614615": {
        //Post_Final_Fine2
        gold_standard_id: "syn21752551",
        docker_input_directory: "/home/ubuntu/validation_dir",
        docker_param_directory: "/home/ubuntu/validation_fine_param_dir",
        score_submission: true,
        cores: 8,
        ram: 30000
       }
    };
    return(dict[inputs.evaluationid])
  }

