## Generic Formatting Guide

### Meta Metadata
- **Key**: unique key by which I can refer to this dataset across publication, prefer FirstAuthorLastName_GeneralSpecies
- **PublicationLink**: Direct link to the publication, or Unpublished
- **PublicationCite**: APA citation
- **DatasetLink**: Direct link to the repo, or how it was accessed (e.g., Personal Correspondance)
- **DatasetCite**: DOI, or other citation

### Metadata
- **Species**: Common name and scientific name
- **Device**: Brand of accelerometer used
- **Axes**: Number of sampling axes (max of 3 per type, 3 types --- acc, gyro, mag)
- **Units**: Measurement unit of the axes, commonly G force but can be any number of things
- **SamplingStyle**: Continuous or in bursts, if in bursts, what sampling protocol
- **SamplingRate**: In Hz
- **SampleSize**: Number of individuals in the dataset
- **NumBehaviours**: Number of behaviours
- **TotalVolume**: Total minutes of data provided in the dataset across all behs and individuals

### Instructions
Relatively detailed instructions of everything that was done to the data to transform it from what was provided in the repo to what is used in our studies. Most changes will be able to be inferred from the provided R code, this section acts as a support.