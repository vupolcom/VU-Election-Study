VU 2021 Election Study: Analysis of pre-wave
================
Wouter van Atteveldt, Nel Ruigrok, Mariken van der Velden

# Data

``` r
d <- read_csv(here("data/intermediate/VUElectionPanel2021_wave0.csv"))
```

``` r
d %>% 
  select(iisID, A2, gender, age, education, region,
         ethnicity, job, internet_use, E1) %>%
  mutate(A2=recode_parties(label(A2, "A2")),
         E1=recode_parties(label(E1, "E1"))) %>%
  group_by(A2) %>%
  summarise(gender = round(mean(gender, na.rm = T),0),
            age = round(mean(age, na.rm = T), 0),
            education = round(median(education, na.rm = T),0),
            region = round(median(region, na.rm = T),0),
            ethnicity = round(median(ethnicity, na.rm = T),0),
            job = round(mean(job, na.rm = T), 0),
            internet_use = round(median(internet_use, na.rm = T),0),
            E1 = mode(E1)) %>%
  mutate(job = label(job, "job"),
         age = label(age, "age"),
         education = label(education, "education"),
         gender = label(gender, "gender"),
         region = label(region, "region"),
         internet_use = label(internet_use, "internet_use"),
         ethnicity = label(ethnicity, "ethnicity"))
```

| A2           | gender | age   | education | region                                             | ethnicity                              | job                                                     | internet\_use                 | E1        |
| :----------- | :----- | :---- | :-------- | :------------------------------------------------- | :------------------------------------- | :------------------------------------------------------ | :---------------------------- | :-------- |
| 50+          | Female | 55-64 | Medium    | East of the country                                | Dutch origin                           | Unemployed and not searching for a job or incapacitated | Much more for private reasons | character |
| Anders       | Female | 45-54 | Medium    | East of the country                                | Dutch origin                           | Unemployed and searching for a job                      | More for private reasons      | character |
| CDA          | Female | 45-54 | Medium    | North of the country                               | Dutch origin                           | Unemployed and searching for a job                      | More for private reasons      | character |
| ChristenUnie | Male   | 45-54 | Medium    | North of the country                               | Dutch origin                           | Entrepreneur                                            | More for private reasons      | character |
| D66          | Female | 45-54 | High      | West of the country                                | Dutch origin                           | Unemployed and searching for a job                      | More for private reasons      | character |
| Denk         | Male   | 25-34 | Medium    | West of the country                                | First generation non-Western immigrant | Entrepreneur                                            | More for work                 | character |
| FvD          | Female | 35-44 | Medium    | West of the country                                | Dutch origin                           | Entrepreneur                                            | More for private reasons      | character |
| GroenLinks   | Male   | 35-44 | High      | North of the country                               | Dutch origin                           | Unemployed and searching for a job                      | More for private reasons      | character |
| Niet         | Female | 45-54 | Medium    | East of the country                                | Dutch origin                           | Entrepreneur                                            | Much more for private reasons | character |
| PvdA         | Male   | 45-54 | Medium    | North of the country                               | Dutch origin                           | Unemployed and searching for a job                      | More for private reasons      | character |
| PvdD         | Male   | 35-44 | Medium    | West of the country                                | Dutch origin                           | Entrepreneur                                            | More for private reasons      | character |
| PVV          | Female | 45-54 | Medium    | North of the country                               | Dutch origin                           | Unemployed and searching for a job                      | Much more for private reasons | character |
| SGP          | Female | 45-54 | Medium    | West of the country                                | Dutch origin                           | Unemployed and searching for a job                      | More for private reasons      | character |
| SP           | Male   | 45-54 | Medium    | North of the country                               | Dutch origin                           | Unemployed and searching for a job                      | Much more for private reasons | character |
| VVD          | Female | 45-54 | Medium    | North of the country                               | Dutch origin                           | Unemployed and searching for a job                      | More for private reasons      | character |
| Weet niet    | Male   | 35-44 | Medium    | North of the country                               | Dutch origin                           | Unemployed and searching for a job                      | More for private reasons      | character |
| NA           | Male   | 35-44 | High      | Three big cities (Amsterdam, Rotterdam, The Hague) | Dutch origin                           | Unemployed and searching for a job                      | Much more for work            | character |
