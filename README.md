# Using Think-Aloud Data to Understand SRL in ITS

Supplementary repository of the manuscript "Using Think-Aloud Data to Understand Relations between Self-Regulation Cycle Characteristics and Student Performance in Intelligent Tutoring Systems" accepted as full paper to LAK '24.

## Citation

Borchers, C., Zhang, J., Baker, R. S., & Aleven, V. (2023). Using Think-Aloud Data to Understand Relations between Self-Regulation Cycle Characteristics and Student Performance in Intelligent Tutoring Systems. In *Proceedings of the 15th International Learning Analytics and Knowledge Conference* (LAK24). ACM. 
```
@inproceedings{borchers2024thinkaloud,
  title={Using Think-Aloud Data to Understand Relations between Self-Regulation Cycle Characteristics and Student Performance in Intelligent Tutoring Systems},
  author={Borchers, Conrad and Zhang, Jiayi and Baker, Ryan S and Aleven, Vincent},
  booktitle={LAK24: 14th International Learning Analytics and Knowledge Conference},
  doi={},
  url={},
  year={2024}
}
```

## Folder structure

* `process-transcripts.ipynb`: Notebook to process think-aloud transcripts from Whisper AI based on native Zoom transcriptions and local transcriptions of audio files. Generates a file adding tutor log data context to transcripts for human labeling of utterances.

* `main-lak24.R` and `lak24-functions.R`: All R analysis code that takes the human-labeled data set based on the output of `process-transcripts.ipynb`. It further creates output for the file `rq3-analysis.ipynb`.

* `rq3-analysis.ipynb`: Analysis code to reproduce results for RQ3.

## Data availability

Data to reproduce all analyses conducted for this study can be requested via [CMU DataShop](https://pslcdatashop.web.cmu.edu/DatasetInfo?datasetId=5371).

