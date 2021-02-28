library(amcatr)
library(glue)
library(here)
library(tidyverse)

source(here("src/lib/amcatlib.R"))

period = function(date) {
  case_when(date < "2021-01-13" ~ "pre",
          date < "2021-01-28" ~ "w0",
          date < "2021-02-11" ~ "w1",
          T ~ "w2")
}
queries = get_party_queries()

conn = amcat.connect("https://vu.amcat.nl")
h = amcat.hits(conn, project=69, sets=c(2562, 2563, 2564), queries=queries$query, labels = queries$partij) %>% 
  as_tibble() %>% rename(party=query)
meta_print = amcat.articles(conn, project=69, articleset=2562, columns = c("date", "publisher", "title")) %>%
  as_tibble() %>%  add_column(mtype="print")
meta_online = amcat.articles(conn, project=69, articleset=2564, columns = c("date", "publisher", "title")) %>%
  as_tibble() %>%  add_column(mtype="online") %>% filter(publisher == "NOS nieuws") %>% mutate(publisher="nos.nl")
meta_tv = amcat.articles(conn, project=69, articleset=2563, columns = c("date", "publisher", "title")) %>% 
  as_tibble() %>% add_column(mtype="tv") %>% mutate(publisher = case_when(
    str_starts(title, "M -") ~ "M", 
    str_starts(title, "NOS Journaal") ~ "NOS Journaal",
    str_starts(title, "Madeleijn van den Nieuwenhuizen")~ "M",
    str_starts(title, "Mart Smeets, Kustaw Bessems") ~ "M",
    str_starts(title, "WNL GOEDEMORGEN NEDERLAND") ~ "GoedemorgenNL",
    T ~ title)) 
meta = bind_rows(meta_print, meta_online, meta_tv) %>% mutate(id=as.numeric(id)) %>% mutate(period=period(date))

h = left_join(h, meta %>% select(-title))

# Periode van waves niet 100% duidelijk, even checken
totals = meta %>% group_by(period) %>% summarize(ntot=n())
parties = h %>% group_by(party) %>% summarize(n=n()) %>% arrange(-n) %>% pull(party)

hpp = h %>% group_by(period, party) %>% summarize(n=n(), .groups="drop") %>% 
  pivot_wider(names_from = "party", values_from="n") %>% pivot_longer(-period, names_to="party") %>%
  inner_join(totals) %>%
  mutate(value=value/ntot, period = as.numeric(as.factor(period)), party=factor(party, levels=parties))

ggplot(hpp, aes(x=period, y=value, color=party)) + geom_line() + 
  facet_wrap("party") + 
  scale_y_continuous(labels = scales::percent_format()) +
  xlab(NULL) + ylab(NULL) + ggtitle("Visibility of parties per wave", "(as percentage of all political news)") +
  ggthemes::theme_hc() + theme(legend.position = "none")


#w0 = read_csv(here("data/intermediate/VUElectionPanel2021_wave0.csv"))
#w1 = read_csv(here("data/intermediate/wave1.csv"))
#w0 %>% group_by(lubridate::floor_date(start_date, "day")) %>% summarize(n=n())
#w1 %>% group_by(lubridate::floor_date(start_date, "day")) %>% summarize(n=n())


