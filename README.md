# Overview

This repository contains supplementary materials for the following conference paper:

[Anonymous authors]\
**Procrastination vs. Active Delay: How Students Prepare to Code in Introductory Programming**\
Submitted to ACM SIGCSE 2024 conference.

# Pre coding analysis
The R file reads in data from the data folder and analyzes how students' pre-coding activities (e.g., days and intensity of using piazza and codio) relate to behavioral delay in starting to code and course grades.

## File structure

### Data

Folders:

* `HW release data`: Programming assignment number, topic, and release date (M/D/YY) in the course.
* `canvas_videos_data_fa20_anon`: Anonymized data on time students watched videos on Canvas (LMS). 
* `del_pre`: The time and date (M/D/YY) students accessed course resources during the course.
* `df_HWGrades`: Students' assignment grades across homeworks 0 to 9.
* `df_Piazza`: Q&A platform data.
* `video_HW_mapping`: Each video published in the course was mapped onto specific programming assignments and programming topics.
* `avg pre-coding activity_2023August03.xlsx`: Average pre-coding activity usage for each homework ranked from highest to lowest with corresponding correlation values (RQ1).


### Code

Files:

* `updated_SIGCSE 2024 precoding`: the script with RQs analyzing students' pre-coding activities and its relation to behavioral delay and performance outcomes.
