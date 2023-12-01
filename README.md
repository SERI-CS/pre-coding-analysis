# Overview

This repository contains supplementary materials for the following conference paper:

Elizabeth B. Cloude, Jiayi Zhang, Ryan S. Baker, and Eric Fouh\
**Procrastination vs. Active Delay: How Students Prepare to Code in Introductory Programming**\
Proceedings of the 55th ACM Technical Symposium on Computer Science Education (V. 1). To be held on March 20--23, 2024 in Portland, OR, USA.

# Pre-coding analysis
The R code file reads data from the files in the data folder and analyzes how students' pre-coding activities (e.g., days and intensity of using piazza and codio) predict behavioral delay in starting to code an assignment and course grades in an introductory computer science course.

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

File:
* `updated_SIGCSE 2024 precoding`: the script with RQs analyzing students' pre-coding activities and its relation to behavioral delay and performance outcomes.
