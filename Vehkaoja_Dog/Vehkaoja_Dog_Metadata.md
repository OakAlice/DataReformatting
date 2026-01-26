
## Vehkaoja_Dog Formatting Guide

### Meta Metadata
- **Key**: Vehkaoja_Dog
- **PublicationLink**: https://www.sciencedirect.com/science/article/pii/S2352340922000348
- **PublicationCite**: Vehkaoja, A., Somppi, S., Törnqvist, H., Cardó, A. V., Kumpulainen, P., Väätäjä, H., ... & Vainio, O. (2022). Description of movement sensor dataset for dog behavior classification. Data in Brief, 40, 107822.
- **DatasetLink**: https://data.mendeley.com/datasets/vxhx934tbn/2 
- **DatasetCite**: Vehkaoja, Antti; Somppi, Sanni; Törnqvist, Heini; Valldeoriola Cardó, Anna; Kumpulainen, Pekka; Väätäjä, Heli; Majaranta, Päivi; Surakka, Veikko; Kujala, Miiamaaria; Vainio, Outi (2022), “Movement Sensor Dataset for Dog Behavior Classification”, Mendeley Data, V2, doi: 10.17632/vxhx934tbn.2

### Metadata
- **Species**: Domestic dog (Canis familiaris)
- **Device**: ActiGraph GT9X Link
- **Axes**: 6 (3 acc, 3 gyro)
- **Units**: Unknown
- **SamplingStyle**: Continuous
- **SamplingRate**: 100
- **SampleSize**: 45
- **NumBehaviours**: 11
- **TotalVolume**: XX

### Instructions
Raw data (csv DogMoveData.csv) originally contained up to 3 behavioural annotations per observation. Only the first column (Behavior_1) was selected as the Activity label. Time was not provided in the original dataset and was therefore estimated as counting up in 1/100ths of a second from the first observation of each individual.