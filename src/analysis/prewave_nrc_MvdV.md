VU 2021 Election Study: Analysis of pre-wave
================
Wouter van Atteveldt, Nel Ruigrok, Mariken van der Velden

# Data

``` r
d <- read_csv(here("data/intermediate/VUElectionPanel2021_wave0.csv"))
```

``` r
#mc <- long_mc() %>%
#+   filter(question!="F2")

tmp <- d %>% 
  select(iisID, A2, Gender = gender, 
         Leeftijd = age, Onderwijsniveau = education, 
         Regio = region, Etniciteit = ethnicity, 
        Werk = job, Internetgebruik = internet_use, E1) %>%
  mutate(A2=recode_parties(label(A2, "A2"))) %>%
  group_by(A2) %>%
  summarise(Gender = round(mean(Gender, na.rm = T),0),
            Leeftijd = round(mean(Leeftijd, na.rm = T), 0),
            Onderwijsniveau = round(median(Onderwijsniveau, 
                                           na.rm = T),0),
            Regio = round(median(Regio, na.rm = T),0),
            Etniciteit = round(median(Etniciteit, na.rm = T),0),
            Werk = round(mean(Werk, na.rm = T), 0),
            Internetgebruik = round(median(Internetgebruik,
                                           na.rm = T),0),
            E1 = round(median(E1,na.rm = T),0)) %>%
  mutate(Werk = label(Werk, "job"),
         Leeftijd = label(Leeftijd, "age"),
         Onderwijsniveau = label(Onderwijsniveau, "education"),
         Gender = label(Gender, "gender"),
         Regio = label(Regio, "region"),
         Internetgebruik = label(Internetgebruik, "internet_use"),
         Etniciteit = label(Etniciteit, "ethnicity"),
         E1 = recode_parties(label(E1, "E1"))) %>%
  pivot_longer(cols = Gender:E1) %>%
  drop_na() %>%
  ggplot(aes(x=A2, y = value)) +
  facet_grid(name~., scales = "free") +
  geom_point() +
  theme_minimal() +
  scale_color_viridis_d() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle=60, hjust=0.95, vjust=.95),
        legend.position="bottom",
        legend.title = element_blank()) 
```
