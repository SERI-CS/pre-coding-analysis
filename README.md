# Overview

This repository contains supplementary materials for the following conference paper:

[Anonymous authors]\
**Procrastination vs. Active Delay: How Students Prepare Delay when they start coding but Benefits Assignment Grades**\
Submitted to ACM SIGCSE 2024 conference.

# Pre coding analysis
The rmd file reads in data from the data folder and analyzes how students' pre-coding activities (e.g. days and intensity of using piazza and codio) relate to HW start time and grades.

## File structure

### Data

Folders:

* `HW release data`: Programming assignment number, topic, and release date (M/D/YY) in the course.
* `canvas_videos_data_fa20_anon`: Anonymized data on time students watched videos on Canvas (LMS). 
* `del_pre`: The time and date (M/D/YY) students accessed course resources during the course.
* `df_HWGrades`: Students' assignment grades across homeworks 0 to 9.
* `df_Piazza`: Q&A platform data.
* `video_HW_mapping`: Each video published in the course was mapped onto specific programming assignments and programming topics.


### Code

Files:

* `pre-coding analysis_final`: students' pre-coding activities and its relation to behavioral delay and performance outcomes. (Developed by J. Zhang)
* `updated_SIGCSE 2024 precoding`: students' pre-coding activities and its relation to behavioral delay and performance outcomes using adjusted B-H correction. (developed by J. Zhang and E. Cloude)
