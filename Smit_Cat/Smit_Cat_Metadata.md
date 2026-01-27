
## Smit_Cat Formatting Guide

### Meta Metadata
- **Key**: Smit_Cat
- **PublicationLink**: 
- **PublicationCite**: 
- **DatasetLink**:
- **DatasetCite**: 

### Metadata
- **Species**: Domestic cat
- **Device**:
- **Axes**: 3 (3 acc)
- **Units**: Unknown
- **SamplingStyle**: Continuous
- **SamplingRate**: 30
- **SampleSize**: 12
- **NumBehaviours**: 
- **TotalVolume**: XX

### Instructions
Joining of raw accelerations with behavioural labels required timestamp alignment. Followed instructions from the github associated with this analysis. (https://github.com/MSmit1992/Chapter1-MLmodel_Validation/blob/main/Step%203%3A%20Data%20preparation/Prep.datasets.R) Importantly, noted that timestamps in the annotations data are in UTC whereas the timestamps in the acceleration data are in NZST. Had to convert annotations to NZST before joining.