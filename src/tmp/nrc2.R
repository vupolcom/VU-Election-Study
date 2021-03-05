library(amcatr)
library(glue)
library(here)
library(tidyverse)

source(here("src/lib/amcatlib.R"))

period = function(date) {
  case_when(date < "2021-01-13" ~ "pre",
          date < "2021-01-28" ~ "w0",
          date < "2021-02-16" ~ "w1",
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


data = list(w0 = read_csv(here("data/intermediate/VUElectionPanel2021_wave0.csv")),
            w1 = read_csv(here("data/intermediate/wave1.csv")),
            w2 = read_csv(here("data/intermediate/wave2.csv"))
)

resp = extract_wide(data$w0)
w = extract_waves(data)

votes = bind_rows(
  w %>% filter(variable == "vote") %>% select(wave, iisID, name),
  resp %>% select(iisID, vote_2017) %>% rename(name = vote_2017) %>% add_column(wave="k17")
)



parties = c("Not", "New", "Undecided", "Other", "PVV", "FvD", "SGP", "SP", "Denk", "PvdD", "50+", "PvdA", "GroenLinks", "D66", "CDA", "ChristenUnie", "VVD", "Average")  

votes = votes %>% na.omit() %>% mutate(waveno=as.numeric(as.factor(wave)), nxt= waveno+1)# %>% mutate(name=ifelse(name %in% c("Not", "Undecided"), "Not/Undecided", name)) 
changes = votes %>% inner_join(votes, by=c("iisID", "nxt"="waveno"), suffix=c("", ".to")) %>% rename(to=name.to) %>% 
  group_by(wave, wave.to, name, to) %>% summarize(n=n()) %>% group_by(wave) %>% mutate(ntot=sum(n), perc=n/ntot, seat=perc*150) %>% ungroup()

undecided_to = changes %>% filter(name %in%  c("Not", "Undecided")) %>% group_by(wave, to) %>% summarize(n=sum(n), seat=sum(seat))%>% select(-n) %>% 
  pivot_wider(values_fill=0, names_from=wave, values_from=seat) %>% pivot_longer(-to, values_to="seat", names_to="wave")

undecided_from = changes %>% filter(to %in%  c("Not", "Undecided")) %>% group_by(wave,name) %>% summarize(n=sum(n), seat=sum(seat))%>% select(-n) %>% 
  pivot_wider(values_fill=0, names_from=wave, values_from=seat) %>% pivot_longer(-name, values_to="seat", names_to="wave")

d = bind_rows(
  undecided_to %>% rename(party=to) %>% add_column(type="Undecided voters went to"),
  undecided_from %>% rename(party=name) %>% add_column(type="New undecided voters from")) %>% 
  filter(party != "Undecided", wave != "k17") %>% mutate(party=factor(party, levels=parties))

setdiff(levels(droplevels(d$party)), parties)

ggplot(d, aes(x=wave, y=party, fill=seat, label=round(seat, 1))) + geom_tile(color="white", lwd=2) + geom_text(color="white") +
  facet_grid(cols=vars(type)) +
  scale_fill_gradient(low="#d0e0f0", high="#01529d", guide=F) + 
  ggthemes::theme_hc() + theme(panel.grid.major.y = element_blank())


edges = changes %>% na.omit() %>% 
  filter(seat > 2) %>% 
  filter(name %in% c("Not", "Undecided") | to %in% c("Not", "Undecided")) %>%
  mutate(
    weight=ifelse(name == to, 99999, seat),
    style=ifelse(name != "Undecided" & name == to, "invis", glue("setlinewidth({seat})")),
    flabel=glue('"{wave}_{name}" -> "{wave.to}_{to}" [label="{round(seat,1)}",weight={weight},style="{style}"];'))
nodes =  edges %>% select(wave, name) %>% bind_rows(edges %>% select(wave=wave.to, name=to)) %>% unique() %>% 
  mutate(nlabel=glue('"{wave}_{name}" [label="{name}"];'))
                             
graph = c("digraph G{",
          "rankdir=LR; nodesep=.5;",
          nodes %>% pull(nlabel),
          edges %>% pull(flabel), 
          "}")
system("dot -Tpng > /tmp/test.png", input = graph)

cat(graph[2])
writeLines(graph, file("/tmp/test.dot"))

votes %>% group_by(wave, name) %>% summarize(n=n()) %>% mutate(ntot=sum(n), seat=n/ntot*150) %>% select(wave, name, seat) %>% pivot_wider(names_from=wave, values_from=seat) %>% write_csv("/tmp/votes.csv")

data$w0 %>% group_by(lubridate::floor_date(start_date, "day")) %>% summarize(n=n())
data$w1 %>% group_by(lubridate::floor_date(start_date, "day")) %>% summarize(n=n())
data$w2 %>% group_by(lubridate::floor_date(start_date, "day")) %>% summarize(n=n())

